#
# makefile to keep buildsystem helpers
#
# -----------------------------------------------------------------------------

# execute local scripts
define local-script
	@if [ -x $(LOCAL_DIR)/scripts/$(1) ]; then \
		$(LOCAL_DIR)/scripts/$(1) $(2) $(TARGET_DIR) $(BUILD_DIR); \
	fi
endef

# -----------------------------------------------------------------------------

# apply patch sets
define apply_patches
	l=$(strip $(2)); test -z $$l && l=1; \
	for i in $(1); do \
		if [ -d $$i ]; then \
			for p in $$i/*; do \
				echo -e "$(TERM_YELLOW)Applying $${p#$(PATCHES)/}$(TERM_NORMAL)"; \
				if [ $${p:0:1} == "/" ]; then \
					patch -p$$l -i $$p; \
				else \
					patch -p$$l -i $(PATCHES)/$$p; \
				fi; \
			done; \
		else \
			echo -e "$(TERM_YELLOW)Applying $${i#$(PATCHES)/}$(TERM_NORMAL)"; \
			if [ $${i:0:1} == "/" ]; then \
				patch -p$$l -i $$i; \
			else \
				patch -p$$l -i $(PATCHES)/$$i; \
			fi; \
		fi; \
	done
endef

# apply patch sets automatically
APPLY_PATCHES = $(call apply_patches, $(PKG_PATCHES_DIR))

# -----------------------------------------------------------------------------

# github(user,package,version): returns site of GitHub repository
github = https://github.com/$(1)/$(2)/archive/$(3)

# -----------------------------------------------------------------------------

# rewrite libtool libraries
REWRITE_LIBTOOL_RULES  = $(SED) "s,^libdir=.*,libdir='$(TARGET_libdir)',; \
				 s,\(^dependency_libs='\| \|-L\|^dependency_libs='\)/lib,\ $(TARGET_libdir),g"

REWRITE_LIBTOOL        = $(REWRITE_LIBTOOL_RULES) $(TARGET_libdir)

REWRITE_LIBTOOL_TAG    = rewritten=1

define rewrite_libtool
	cd $(TARGET_libdir); \
	LA=$$(find . -name "*.la" -type f); \
	for la in $${LA}; do \
		if ! grep -q "$(REWRITE_LIBTOOL_TAG)" $${la}; then \
			echo -e "$(TERM_YELLOW)Rewriting $${la}$(TERM_NORMAL)"; \
			$(REWRITE_LIBTOOL)/$${la}; \
			echo -e "\n# Adapted to buildsystem\n$(REWRITE_LIBTOOL_TAG)" >> $${la}; \
		fi; \
	done
endef

# rewrite libtool libraries automatically
REWRITE_LIBTOOL_LA = $(call rewrite_libtool)

# -----------------------------------------------------------------------------

# rewrite pkg-config files
REWRITE_CONFIG_RULES   = $(SED) "s,^prefix=.*,prefix='$(TARGET_prefix)',; \
				 s,^exec_prefix=.*,exec_prefix='$(TARGET_exec_prefix)',; \
				 s,^libdir=.*,libdir='$(TARGET_libdir)',; \
				 s,^includedir=.*,includedir='$(TARGET_includedir)',"

REWRITE_CONFIG         = $(REWRITE_CONFIG_RULES)
REWRITE_PKGCONF        = $(REWRITE_CONFIG_RULES) $(PKG_CONFIG_PATH)

REWRITE_CONFIG_TAG     = rewritten=1

define rewrite_pkgconf
	cd $(PKG_CONFIG_PATH); \
	PC=$$(find . -name "*.pc" -type f); \
	for pc in $${PC}; do \
		if ! grep -q "$(REWRITE_CONFIG_TAG)" $${pc}; then \
			echo -e "$(TERM_YELLOW)Rewriting $${pc}$(TERM_NORMAL)"; \
			$(REWRITE_PKGCONF)/$${pc}; \
			echo -e "\n$(REWRITE_CONFIG_TAG)" >> $${pc}; \
		fi; \
	done
endef

# rewrite pkg-config files automatically
REWRITE_PKGCONF_PC = $(call rewrite_pkgconf)

# -----------------------------------------------------------------------------

#
# Manipulation of .config files based on the Kconfig infrastructure.
# Used by the BusyBox package, the Linux kernel package, and more.
#

define KCONFIG_ENABLE_OPT # (option, file)
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo '$(1)=y' >> $(2)
endef

define KCONFIG_SET_OPT # (option, value, file)
	$(SED) "/\\<$(1)\\>/d" $(3)
	echo '$(1)=$(2)' >> $(3)
endef

define KCONFIG_DISABLE_OPT # (option, file)
	$(SED) "/\\<$(1)\\>/d" $(2)
	echo '# $(1) is not set' >> $(2)
endef

# -----------------------------------------------------------------------------

#
# Case conversion macros.
#

[LOWER] := a b c d e f g h i j k l m n o p q r s t u v w x y z
[UPPER] := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

define caseconvert-helper
$(1) = $$(strip \
	$$(eval __tmp := $$(1))\
	$(foreach c, $(2),\
		$$(eval __tmp := $$(subst $(word 1,$(subst :, ,$c)),$(word 2,$(subst :, ,$c)),$$(__tmp))))\
	$$(__tmp))
endef

$(eval $(call caseconvert-helper,UPPERCASE,$(join $(addsuffix :,$([LOWER])),$([UPPER]))))
$(eval $(call caseconvert-helper,LOWERCASE,$(join $(addsuffix :,$([UPPER])),$([LOWER]))))

# -----------------------------------------------------------------------------

#
# $(1) = title
# $(2) = color
#	0 - Black
#	1 - Red
#	2 - Green
#	3 - Yellow
#	4 - Blue
#	5 - Magenta
#	6 - Cyan
#	7 - White
# $(3) = left|center|right
#
define draw_line
	@ \
	printf '%.0s-' {1..$(shell tput cols)}; \
	if test "$(1)"; then \
		cols=$(shell tput cols); \
		length=$(shell echo $(1) | awk '{print length}'); \
		case "$(3)" in \
			*right)  let indent="length + 1" ;; \
			*center) let indent="cols - (cols - length) / 2" ;; \
			*left|*) let indent="cols" ;; \
		esac; \
		tput cub $$indent; \
		test "$(2)" && printf $$(tput setaf $(2)); \
		printf '$(1)'; \
		test "$(2)" && printf $$(tput sgr0); \
	fi; \
	echo
endef

# -----------------------------------------------------------------------------

archives-list:
	@rm -f $(BUILD_DIR)/$(@)
	@make -qp | grep --only-matching '^\$(DL_DIR).*:' | sed "s|:||g" > $(BUILD_DIR)/$(@)

DOCLEANUP ?= no
GETMISSING ?= no
archives-info: archives-list
	@echo "[ ** ] Unused targets in make/archives.mk"
	@grep --only-matching '^\$$(DL_DIR).*:' make/archives.mk | sed "s|:||g" | \
	while read target; do \
		found=false; \
		for makefile in make/*.mk; do \
			if [ "$${makefile##*/}" = "archives.mk" ]; then \
				continue; \
			fi; \
			if [ "$${makefile: -9}" = "-extra.mk" ]; then \
				continue; \
			fi; \
			if grep -q "$$target" $$makefile; then \
				found=true; \
			fi; \
			if [ "$$found" = "true" ]; then \
				continue; \
			fi; \
		done; \
		if [ "$$found" = "false" ]; then \
			echo -e "[$(TERM_RED) !! $(TERM_NORMAL)] $$target"; \
		fi; \
	done;
	@echo "[ ** ] Unused archives"
	@find $(DL_DIR)/ -maxdepth 1 -type f | \
	while read archive; do \
		if ! grep -q $$archive $(BUILD_DIR)/archives-list; then \
			echo -e "[$(TERM_YELLOW) rm $(TERM_NORMAL)] $$archive"; \
			if [ "$(DOCLEANUP)" = "yes" ]; then \
				rm $$archive; \
			fi; \
		fi; \
	done;
	@echo "[ ** ] Missing archives"
	@cat $(BUILD_DIR)/archives-list | \
	while read archive; do \
		if [ -e $$archive ]; then \
			#echo -e "[$(TERM_GREEN) ok $(TERM_NORMAL)] $$archive"; \
			true; \
		else \
			echo -e "[$(TERM_YELLOW) -- $(TERM_NORMAL)] $$archive"; \
			if [ "$(GETMISSING)" = "yes" ]; then \
				make $$archive; \
			fi; \
		fi; \
	done;
	@$(REMOVE)/archives-list

# -----------------------------------------------------------------------------

# FIXME - how to resolve variables while grepping makefiles?
patches-info:
	@echo "[ ** ] Unused patches"
	@for patch in $(PATCHES)/*; do \
		if [ ! -f $$patch ]; then \
			continue; \
		fi; \
		patch=$${patch##*/}; \
		found=false; \
		for makefile in make/*.mk; do \
			if grep -q "$$patch" $$makefile; then \
				found=true; \
			fi; \
			if [ "$$found" = "true" ]; then \
				continue; \
			fi; \
		done; \
		if [ "$$found" = "false" ]; then \
			echo -e "[$(TERM_RED) !! $(TERM_NORMAL)] $$patch"; \
		fi; \
	done;

# -----------------------------------------------------------------------------

PHONY += archives-list
PHONY += archives-info
PHONY += patches-info
