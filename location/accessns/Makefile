include ../../Makefile
DEPS = $(DEPS) accessns.xsl

makelocations.sh: accessns.xml newlocation.xml mkdirs.xsl
	$(XSLT) mkdirs.xsl accessns.xml > $@
	chmod a+x $@

locations: makelocations.sh
	./makelocations.sh

recursive: locations