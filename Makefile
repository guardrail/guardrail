#!/usr/bin/make -f

# this rule makes tag or branch targets
%:
	./makexpi.sh $@
# this makes prerelease xpis (and is the default rule)
prerelease: pkg
	./makexpi.sh
pkg:
	mkdir pkg
clean:
	rm -f pkg/*.xpi src/install.rdf guardrail-latest-update.rdf

.PHONY: clean prerelease
