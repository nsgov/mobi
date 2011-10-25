# This Makefile is used in all directories of the project, so calculate where in the project tree we are
RELROOT  := $(shell printf .; while [ ! -f site.conf ]; do cd ..; printf /..; done)
PROJROOT := $(realpath $(RELROOT))
URLPATH  := $(patsubst $(PROJROOT)%,%,$(realpath .))/
XMLFILE  := $(notdir homepage$(URLPATH:%/=%)).xml

# Generate pages for different languages
LANGS        := en fr
DEFAULT_LANG := $(firstword $(LANGS))
XHTML_FILES  := $(addsuffix .xhtml,$(LANGS:$(DEFAULT_LANG)=index))
HTML_FILES   := $(XHTML_FILES:.xhtml=.html)

# Figure out the directories in which to invoke make (those with dir/Makefile or dir/dir.xml)
ALL_DIRS            := $(wildcard */)
DIRS_WITH_MAKEFILES := $(dir $(wildcard */Makefile))
DIRS_XML            := $(wildcard $(join $(ALL_DIRS),$(ALL_DIRS:%/=%.xml)))
DIRS_WITH_XML       := $(dir $(DIRS_XML))
DIRS                := $(sort $(DIRS_WITH_MAKEFILES) $(DIRS_WITH_XML))

# Misc variables
XSLT := xsltproc
DEFAULT_TARGETS := $(HTML_FILES)
BIN := $(PROJROOT)/bin
XSLDEPS := $(shell $(XSLT) $(RELROOT)/xsl/xsldeps.xsl $(XMLFILE))
DEPS := .path.xml $(XSLDEPS) Makefile $(RELROOT)/Makefile
TIDY_CONF := $(PROJROOT)/tidy.conf
TIDY_FLAGS := -config "$(TIDY_CONF)"
LASTMOD := $(shell python "$(BIN)/lastmod.py" $(XMLFILE))

# 1 Rainbow was harmed in the making of this Makefile, in order to add color to errors, warnings, etc.
W_CLR := [0;43m
E_CLR := [1;37;41m
B_CLR := [1m
D_CLR := [0;37;44m
N_CLR := [0;39;49m[K

.PHONY: main xhtml all clean allclean fresh site stage Makefiles recursive
#.INTERMEDIATE: $(XHTML_FILES)

main: $(DEFAULT_TARGETS)

%.html: %.xhtml $(TIDY_CONF)
	@printf '$(B_CLR)tidy$(N_CLR) $(TIDY_FLAGS) -o $(B_CLR)$@$(N_CLR) $<'"\n$(W_CLR)"
	@tidy $(TIDY_FLAGS) -o "$@" "$<" || (printf "$(N_CLR)"; false)
	@printf "$(N_CLR)"

%.xhtml: $(XMLFILE) $(DEPS) $(DIRS_XML)
	@printf '$(B_CLR)$(XSLT)$(N_CLR) --stringparam lang $(*:index=$(DEFAULT_LANG)) --stringparam lastmod $(LASTMOD) $< -o $(B_CLR)$@'"\n$(W_CLR)"
	@$(XSLT) --stringparam lang $(*:index=$(DEFAULT_LANG)) --stringparam lastmod $(LASTMOD) $< -o $@ || (printf "$(N_CLR)"; exit 1)
	@printf "$(N_CLR)"

xhtml: $(XHTML_FILES)

all: main recursive
	@for d in $(DIRS); do \
		$(MAKE) -C $$d -q || echo "$(D_CLR)$(URLPATH)$$d$(N_CLR):"; \
		$(MAKE) -C $$d --no-print-directory all  || (echo "$(E_CLR) * Make failed in \"$(URLPATH)$$d\" * $(N_CLR)" 1>&2; exit 1); \
	done

clean:
	rm -f $(DEFAULT_TARGETS) $(XHTML_FILES)
	@rm -f .id.xml .path.xml index.*html fr.*html

allclean: clean recursive
	@for d in $(DIRS); do \
		$(MAKE) -f "$(PROJROOT)/Makefile" -C $$d -s allclean; \
	done

fresh: allclean all

site:
	$(MAKE) -C $(RELROOT) fresh

stage:
	ssh mobile@cnsdev.ca 'cd stage && git pull && make all'

.path.xml: . $(RELROOT)/Makefile
	@echo "<path basename='$(basename $(XMLFILE))' root='$(RELROOT:./%=%)'>$(URLPATH:%/=%)</path>" > $@

Makefiles: recursive
	@for d in $(DIRS); do \
		$(MAKE) -C $$d --no-print-directory Makefiles; \
	done

recursive:
	@for d in $(DIRS_WITH_XML:%/=%); do \
		if [ ! -f $$d/Makefile ]; then \
			echo "$(D_CLR) Making $(URLPATH)$$d/Makefile$(N_CLR) "; \
			echo "include .$(RELROOT)/Makefile" > $$d/Makefile; \
		fi; \
	done

tally:
	@for d in . $(DIRS); do \
		if [ "$$d" != . ]; then c=`find $$d -name '*.html'|wc -l`; else c=`/bin/ls -1 *.html 2>/dev/null|wc -l`; fi;\
		printf "$(B_CLR)%8d$(N_CLR) pages in $(D_CLR)%s$(N_CLR)\n" $$c "$$d" &&\
		total=`expr $${total=0} + $$c`;\
	done; [ -t 1 ] && echo "========"; printf "$(B_CLR)%8d$(N_CLR) pages in Total\n" $$total

apparent: .path.xml
	@echo xml: $(XMLFILE)
	@echo xsl: $(XSLDEPS)
	@echo xhtml: $(XHTML_FILES)
	@echo html: $(HTML_FILES)
	@echo dirs: $(DIRS)
	@echo url: $(URLPATH)
	@echo proj: $(PROJROOT)
	@cat .path.xml

