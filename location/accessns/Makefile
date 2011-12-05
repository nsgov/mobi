DEPS := $(DEPS) accessns.xsl locations.xml
include ../../Makefile

locations.xml: Makefile
	curl -O 'http://www.gov.ns.ca/snsmr/xml/locations.xml'

makelocations.sh: accessns.xml newlocation.xml mkdirs.xsl
	$(XSLT) mkdirs.xsl accessns.xml > $@
	chmod a+x $@

recursive: locations.xml
