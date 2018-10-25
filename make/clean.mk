# clean all for rebuild (except the toolchain)

rebuild-clean:
	-rm -rf $(BUILD_TMP)
	-rm -rf $(TARGET_DIR)
	-rm -rf $(D)

staging-clean:
	-rm -rf $(STAGING_DIR)

static-clean:
	-rm -rf $(STATIC_DIR)

cross-clean:
	-rm -rf $(CROSS_DIR)

host-clean:
	-rm -rf $(HOST_DIR)

all-clean: rebuild-clean staging-clean static-clean
	@echo -e "\n$(TERM_RED_BOLD)Any other key then CTRL-C will now remove CROSS_DIR and HOST_DIR$(TERM_NORMAL)"
	@read
	make cross-clean
	make host-clean

%-clean:
	cd $(D) && find . -name $(subst -clean,,$@) -delete

clean: rebuild-clean bootstrap

clean-all:
	make update-all
	make staging-clean
	make clean

ccache-clean:
	@echo "Clearing $$CCACHE_DIR"
	@$(CCACHE) -C

# -----------------------------------------------------------------------------

PHONY += rebuild-clean
PHONY += staging-clean
PHONY += stytic-clean
PHONY += all-clean
PHONY += %-clean
PHONY += clean
PHONY += clean-all
PHONY += ccache-clean
