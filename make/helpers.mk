#
# makefile to keep buildsystem helpers
#
# -----------------------------------------------------------------------------

# execute local scripts
define local-script
	@if [ -x $(LOCAL_DIR)/scripts/$(1) ]; then \
		$(LOCAL_DIR)/scripts/$(1) $(2) $(TARGET_DIR) $(BUILD_TMP); \
	fi
endef

# -----------------------------------------------------------------------------

# apply patch sets
define apply_patches
	l=`echo $(2)`; test -z $$l && l=1; \
	for i in $(1); do \
		if [ -d $$i ]; then \
			for p in $$i/*; do \
				echo -e "$(TERM_YELLOW)Applying $$p$(TERM_NORMAL)"; \
				if [ $${p:0:1} == "/" ]; then \
					patch -p$$l -i $$p; \
				else \
					patch -p$$l -i $(PATCHES)/$$p; \
				fi; \
			done; \
		else \
			echo -e "$(TERM_YELLOW)Applying $$i$(TERM_NORMAL)"; \
			if [ $${i:0:1} == "/" ]; then \
				patch -p$$l -i $$i; \
			else \
				patch -p$$l -i $(PATCHES)/$$i; \
			fi; \
		fi; \
	done
endef

# -----------------------------------------------------------------------------

archives-list:
	@rm -f $(BUILD_TMP)/$@
	@make -qp | grep --only-matching '^\$(ARCHIVE).*:' | sed "s|:||g" > $(BUILD_TMP)/$@

DOCLEANUP ?= no
GETMISSING ?= no
archives-info: archives-list
	@echo "[ ** ] Unused targets in make/archives.mk"
	@grep --only-matching '^\$$(ARCHIVE).*:' make/archives.mk | sed "s|:||g" | \
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
	@find $(ARCHIVE)/ -maxdepth 1 -type f | \
	while read archive; do \
		if ! grep -q $$archive $(BUILD_TMP)/archives-list; then \
			echo -e "[$(TERM_YELLOW) rm $(TERM_NORMAL)] $$archive"; \
			if [ "$(DOCLEANUP)" = "yes" ]; then \
				rm $$archive; \
			fi; \
		fi; \
	done;
	@echo "[ ** ] Missing archives"
	@cat $(BUILD_TMP)/archives-list | \
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
