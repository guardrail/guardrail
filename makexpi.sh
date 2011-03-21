#!/bin/sh
APP_NAME=guardrail

# builds a .xpi from the git repository, placing the .xpi in the root
# of the repository.

# invoke with no arguments to pull a prerelease of the current
# development point.

# invoke with the literal argument "uncommitted" to build from the
# current src directory.

# invoke with a tag name to build a specific branch or tag.

# e.g.:
#  ./makexpi.sh 0.2.3.development.2

# or just:
#  ./makexpi.sh

# BUGS: if you have a branch or tagged named "uncommitted" then this
# is kind of ambiguous.  Also, the validation of rule syntax is done
# against the rules in the current directory, not necessarily the
# committed rules in git.

cd "$(dirname $0)"

[ -e makexpi.local ] && . ./makexpi.local

if ./trivial-validate src/chrome/content/rules >&2
then
  echo Validation of included rulesets completed. >&2
  echo >&2
else
  echo ERROR: Validation of rulesets failed. >&2
  exit 1
fi

VERSION="0.9.9.development.$(date +%s)"

XPI_NAME="pkg/$VERSION.xpi"
[ -d pkg ] || mkdir pkg

cd "src"

sed -e "s/%VERSION%/$VERSION/g" < install.rdf.tmpl > install.rdf

zip -X -q -9r "../$XPI_NAME" . "-x@../.gitignore" -xinstall.rdf.tmpl

ret="$?"
if [ "$ret" != 0 ]; then
    rm -f "../$XPI_NAME"
    exit "$?"
else
  printf >&2 "Total included rules: $(ls chrome/content/rules/*.xml | wc -l)\n"
  printf >&2 "Rules disabled by default: $(grep -lr default_off chrome/content/rules | wc -l)\n"
  printf >&2 "Created %s\n" "$XPI_NAME"
fi

if [ -x "$UHURA" ]; then
    echo "Generating update.rdf..." >&2
    if [ -z "$KEYFILE" -o -z "$UPDATE_BASEURL" ]; then
        echo "Either KEYFILE or UPDATE_BASEURL are not specified. Exiting." >&2
        exit 1
    fi
    [ -e ../pkg/latest-update.rdf ] && rm -f ../pkg/latest-update.rdf
    "$UHURA" -o ../pkg/latest-update.rdf -a sha512 -k "$KEYFILE" -h -v ../"$XPI_NAME" "$UPDATE_BASEURL$(basename "$XPI_NAME")"
else
    echo "No working Uhura installation found, not generating update.rdf." >&2
fi

ln -sf "$(basename "$XPI_NAME")" "../pkg/latest.xpi"

for i in 1 256 512; do
    echo "Generating sha${i}sums..." >&2
    sha${i}sum ../pkg/*.xpi ../pkg/*.rdf | sed -e 's,\.\./pkg/,,' > ../pkg/SHA${i}SUMS
    if [ -d "$GPGDIR" ]; then
        gpg --homedir="$GPGDIR" --digest-algo SHA$i --clearsign > ../pkg/SHA${i}SUMS.signed < ../pkg/SHA${i}SUMS
    fi
done
