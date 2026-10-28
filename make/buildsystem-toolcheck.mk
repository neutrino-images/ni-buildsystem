#
# makefile for basic toolcheck
#
# -----------------------------------------------------------------------------

TOOLCHECK  =

TOOLCHECK += find-git
TOOLCHECK += find-svn
TOOLCHECK += find-hg
TOOLCHECK += find-cvs

TOOLCHECK += find-curl
TOOLCHECK += find-wget

TOOLCHECK += find-tar
TOOLCHECK += find-lzma
TOOLCHECK += find-zip
TOOLCHECK += find-unzip
TOOLCHECK += find-bzip2
TOOLCHECK += find-gzip
TOOLCHECK += find-xz

TOOLCHECK += find-gawk
TOOLCHECK += find-grep
TOOLCHECK += find-sed
TOOLCHECK += find-find
TOOLCHECK += find-bc
TOOLCHECK += find-tput

TOOLCHECK += find-g++
TOOLCHECK += find-gcc
TOOLCHECK += find-ccache
TOOLCHECK += find-automake
TOOLCHECK += find-autoconf
TOOLCHECK += find-libtoolize
TOOLCHECK += find-libtool

TOOLCHECK += find-patch
TOOLCHECK += find-pkg-config
TOOLCHECK += find-gettextize
TOOLCHECK += find-autopoint
TOOLCHECK += find-intltoolize
TOOLCHECK += find-gtkdocize

TOOLCHECK += find-gperf
TOOLCHECK += find-bison
TOOLCHECK += find-help2man
TOOLCHECK += find-makeinfo
TOOLCHECK += find-flex

find-%:
	@TOOL=$(patsubst find-%,%,$(@)); which $$TOOL $(if $(VERBOSE),,>/dev/null) || \
		{ $(call WARNING,"Warning",": required tool $$TOOL missing."); false; }

bashcheck:
	@test "$(findstring /bash,$(shell readlink -f /bin/sh))" == "/bash" || \
		{ $(call WARNING,"Warning",": /bin/sh is not linked to bash"); false; }

toolcheck: bashcheck $(TOOLCHECK)
	@$(call SUCCESS,"toolcheck",": All required tools seem to be installed.")

# -----------------------------------------------------------------------------

CROSSCHECK  =
CROSSCHECK += $(TARGET_CC)
CROSSCHECK += $(TARGET_CPP)
CROSSCHECK += $(TARGET_CXX)

crosscheck:
	@for c in $(CROSSCHECK); do \
		if test -e $$c; then \
			$(call SUCCESS,"$$c",": found."); \
		elif test -e $(CROSS_DIR)/bin/$$c; then \
			$(call SUCCESS,"$$c",": found in \$$(CROSS_DIR)/bin"); \
		elif PATH=$(PATH) type -p $$c >/dev/null 2>&1; then \
			$(call SUCCESS,"$$c",": found PATH"); \
		else \
			$(call WARNING,"$$c",": not found in \$$(CROSS_DIR)/bin or PATH"); \
			$(call WARNING,"=> please check your setup. Maybe you need to 'make crosstool'."); \
		fi; \
	done

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

# check that parsing the makefiles uses no undefined variable, for all boxes
# (BOXSERIES or BOXFAMILY in config.local would win over BOXMODEL; so set
# only BOXMODEL there)
varcheck:
	@rc=0; \
	for boxmodel in $(BOXMODELS); do \
		output=$$(LC_ALL=C $(MAKE) -n --warn-undefined-variables \
			BOXMODEL=$$boxmodel .print-phony 2>&1 >/dev/null); \
		problems=$$(echo "$$output" | grep -e "warning: undefined variable" -e "\*\*\*" | sort -u); \
		if [ -n "$$problems" ]; then \
			$(call WARNING,"$$boxmodel",":"); \
			echo "$$problems"; \
			rc=1; \
		fi; \
	done; \
	if [ $$rc -eq 0 ]; then \
		$(call SUCCESS,"varcheck",": No undefined variables."); \
	fi; \
	exit $$rc

# -----------------------------------------------------------------------------

PHONY += toolcheck
PHONY += bashcheck
PHONY += crosscheck
PHONY += varcheck
