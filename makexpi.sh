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

if ./trivial-validate src/chrome/content/rules >&2
then
  echo Validation of included rulesets completed. >&2
  echo >&2
else
  echo ERROR: Validation of rulesets failed. >&2
  exit 1
fi

VERSION="0.9.9.development.$(date +%s)"

XPI_NAME="pkg/$APP_NAME-$VERSION.xpi"
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

ln -sf "$XPI_NAME" "../$APP_NAME-latest.xpi"
SHA1=$(sha1sum "../$XPI_NAME"|cut -d" " -f1)
sed -e "s/%VERSION%/$VERSION/g" -e "s/%SHA1%/$SHA1/" < ../update.rdf.tmpl > ../$APP_NAME-latest-update.rdf
