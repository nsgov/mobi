XSLT = xsltproc
CWD = $(shell basename $$PWD)
XMLFILE  = $(shell [ -f site.conf ] && echo homepage || echo $(CWD)).xml
ENGLISH_HTML = index.html
FRENCH_HTML = fr.html
DEFAULT_TARGETS = $(ENGLISH_HTML) $(shell if grep -s lang=.fr. $(XMLFILE) > /dev/null; then echo $(FRENCH_HTML); fi)
DIRS = $(shell for d in */; do [ -f $$d/Makefile ] && printf "%s " $$d; done)
RELROOT = $(shell printf .; while [ ! -f site.conf ]; do cd ..; printf /..; done)
PROJROOT = $(shell cd $(RELROOT); echo $$PWD)
RELPATH = $(shell echo $$PWD | sed -e "s:^$(PROJROOT):.:")
DEPS = Makefile .id.xml $(RELROOT)/Makefile $(RELROOT)/xsl/*.xsl 
H_CLR = $(shell printf "%b" "\033[0;37;44m")
E_CLR = $(shell printf "%b" "\033[1;37;41m")
N_CLR = $(shell printf "%b" "\033[0;39;49m")

pages: $(DEFAULT_TARGETS)

$(ENGLISH_HTML): $(XMLFILE) $(DEPS)
	$(XSLT) --stringparam lang en $< -o $@

$(FRENCH_HTML): $(XMLFILE) $(DEPS)
	$(XSLT) --stringparam lang fr $< -o $@

all: $(DEFAULT_TARGETS) recursive
	@for d in $(DIRS); do \
		echo "$(H_CLR)$(RELPATH)/$$d$(N_CLR):"; \
		$(MAKE) -C $$d --no-print-directory all  || echo "$(E_CLR) * Make failed in \"$(RELPATH)/$$d\" * $(N_CLR)" 1>&2; \
	done

clean:
	rm -f $(ENGLISH_HTML) $(FRENCH_HTML) .id.xml

allclean: clean recursive
	@for d in $(DIRS); do \
		echo "$(H_CLR) - Cleaning \"$(RELPATH)/$$d\" - $(N_CLR)"; \
		$(MAKE) -C $$d  --no-print-directory allclean; \
	done

fresh: allclean all

site:
	$(MAKE) -C $(RELROOT) fresh

stage:
	ssh mobile@cnsdev.ca 'cd stage && git pull && make all'

.id.xml: . $(RELROOT)/Makefile
	@echo "<id>`basename $(XMLFILE) .xml`</id>" > $@

recursive:
