.SUFFIXES:
.SUFFIXES: .xml .xhtml .html .svg .svgz
XSLT = xsltproc
CWD = $(shell basename $$PWD)
XMLFILE  = $(shell [ -f site.conf ] && echo homepage || echo $(CWD)).xml
ENGLISH_XHTML = index.xhtml
FRENCH_XHTML = fr.xhtml
ENGLISH_HTML = index.html
FRENCH_HTML = fr.html
HTML_TARGETS = $(ENGLISH_HTML) $(shell if grep -s lang=.fr. $(XMLFILE) > /dev/null; then echo $(FRENCH_HTML); fi)
DEFAULT_TARGETS = $(HTML_TARGETS)
DIRS = $(shell for d in */; do d=`basename $$d`; [ -f $$d/$$d.xml ] || [ -f $$d/Makefile ] && printf "%s " $$d; done)
RELROOT = $(shell printf .; while [ ! -f site.conf ]; do cd ..; printf /..; done)
PROJROOT = $(shell cd $(RELROOT); echo $$PWD)
URLPATH = $(shell echo $$PWD | sed -e "s:^$(PROJROOT)::")/
BIN = $(PROJROOT)/bin
XSLDEPS = $(shell $(XSLT) $(RELROOT)/xsl/xsldeps.xsl $(XMLFILE))
DEPS = .path.xml $(XSLDEPS) Makefile $(RELROOT)/Makefile
TIDY_CONF = $(PROJROOT)/tidy.conf
TIDY_FLAGS = -config "$(TIDY_CONF)"
LASTMOD = $(shell python "$(BIN)/lastmod.py" $(XMLFILE))
D_CLR = [0;37;44m
TIDY_CLR = [0;43m
E_CLR = [1;37;41m
N_CLR = [0;39;49m[K

main: $(DEFAULT_TARGETS) $(DEPS)

.xhtml.html: $(TIDY_CONF)
	@printf 'tidy $(TIDY_FLAGS) -o "$@" "$<"'"\n$(TIDY_CLR)"
	@tidy $(TIDY_FLAGS) -o "$@" "$<"
	@printf "$(N_CLR)"

$(ENGLISH_XHTML): $(XMLFILE) $(DEPS)
	$(XSLT) --stringparam lang en --stringparam lastmod $(LASTMOD) $< -o $@

$(FRENCH_XHTML): $(XMLFILE) $(DEPS)
	$(XSLT) --stringparam lang fr --stringparam lastmod $(LASTMOD) $< -o $@

all: main recursive
	@for d in $(DIRS); do \
		$(MAKE) -C $$d -q || echo "$(D_CLR)$(URLPATH)$$d$(N_CLR):"; \
		$(MAKE) -C $$d --no-print-directory all  || echo "$(E_CLR) * Make failed in \"$(URLPATH)$$d\" * $(N_CLR)" 1>&2; \
	done

clean:
	rm -f $(ENGLISH_HTML) $(FRENCH_HTML) $(ENGLISH_XHTML) $(FRENCH_XHTML)
	@rm -f .id.xml .path.xml

allclean: clean recursive
	@for d in $(DIRS); do \
		echo "$(D_CLR) - Cleaning \"$(URLPATH)$$d\" - $(N_CLR)"; \
		$(MAKE) -C $$d  --no-print-directory allclean; \
	done

fresh: allclean all

site:
	$(MAKE) -C $(RELROOT) fresh

stage:
	ssh mobile@cnsdev.ca 'cd stage && git pull && make all'

.path.xml: . $(RELROOT)/Makefile
	@echo "<path basename='`basename $(XMLFILE) .xml`' root='`echo $(RELROOT)|cut -c 3-`'>`dirname $(URLPATH)x`</path>" > $@

Makefiles: recursive
	@for d in $(DIRS); do \
		$(MAKE) -C $$d --no-print-directory Makefiles; \
	done

recursive:
	@for d in $(DIRS); do \
		if [ ! -f $$d/Makefile ]; then \
			echo "$(D_CLR) Making $(URLPATH)$$d/Makefile$(N_CLR) "; \
			echo "include .$(RELROOT)/Makefile" > $$d/Makefile; \
		fi; \
	done
