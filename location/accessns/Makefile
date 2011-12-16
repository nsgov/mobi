DEPS := $(DEPS) accessns.xsl locations.xml
include ../../Makefile

index.xhtml: locations contentlinks.xml

locations.xml:
	curl -O 'http://www.gov.ns.ca/snsmr/xml/locations.xml' -z '$@'

contentlinks.xml: contentlinks.xsl locations.xml
	$(XSLT) $+ | uniq > $@

makelocations.sh: mkdirs.xsl contentlinks.xml
	$(XSLT) $+ > $@

locations: makelocations.sh
	sh $<

clean: cleanaccess

cleanaccess:
	rm locations.xml contentlinks.xml makelocations.sh 
	for d in */Makefile; do rm -r "`dirname $$d`"; done;

recursive: locations.xml
