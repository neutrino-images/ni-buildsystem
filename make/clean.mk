#
# makefile for clean targets
#
# -----------------------------------------------------------------------------

rebuild-clean:
	-rm -rf $(BUILD_TMP)
	-rm -rf $(TARGET_DIR)
	-rm -rf $(D)

staging-clean:
	-rm -rf $(STAGING_DIR)

static-clean:
	-rm -rf $(STATIC_DIR)

static-base-clean:
	-rm -rf $(STATIC_BASE)

cross-clean:
	-rm -rf $(CROSS_DIR)

cross-base-clean:
	-rm -rf $(CROSS_BASE)

host-clean:
	-rm -rf $(HOST_DIR)

ccache-clean:
	@echo "Clearing $$CCACHE_DIR"
	@$(CCACHE) -C

all-clean: rebuild-clean staging-clean host-clean static-base-clean
	@echo -e "\n$(TERM_RED_BOLD)Any other key then CTRL-C will now remove CROSS_BASE$(TERM_NORMAL)"
	@read
	make cross-base-clean

%-clean:
	cd $(D) && find . -name $(subst -clean,,$@) -delete

clean: rebuild-clean bootstrap

clean-all:
	make update-all
	make staging-clean
	make clean

# -----------------------------------------------------------------------------

PHONY += rebuild-clean
PHONY += staging-clean
PHONY += static-clean
PHONY += static-base-clean
PHONY += cross-clean
PHONY += cross-base-clean
PHONY += host-clean
PHONY += ccache-clean
PHONY += all-clean
PHONY += %-clean
PHONY += clean
PHONY += clean-all
