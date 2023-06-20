#
# makefile for clean targets
#
# -----------------------------------------------------------------------------

build-clean:
	-rm -rf $(BUILD_DIR)

cross-base-clean:
	-rm -rf $(CROSS_BASE)

cross-clean:
	-rm -rf $(CROSS_DIR)

deps-clean:
	-rm -rf $(DEPS_DIR)

host-clean:
	-rm -rf $(HOST_DIR)

host-bin-config-clean:
	-find $(HOST_DIR)/bin -name *-config ! -name *pkg-config -delete

staging-clean:
	-rm -rf $(STAGING_DIR)

target-clean:
	-rm -rf $(TARGET_DIR)

ccache-clean:
	@echo "Clearing $$CCACHE_DIR"
	@$(CCACHE) -C

rebuild-clean: host-bin-config-clean target-clean deps-clean build-clean checkout-branches

all-clean: rebuild-clean staging-clean host-clean
	@$(call WARNING,"Any other key then CTRL-C will now remove CROSS_BASE")
	@read
	make cross-base-clean

clean: rebuild-clean bootstrap

distclean: staging-clean clean

clean-all: update-all distclean

%-clean:
	-find $(if $(findstring host-,$(@)),$(HOST_DEPS_DIR),$(DEPS_DIR)) -name $(subst -clean,,$(@)) -delete

# -----------------------------------------------------------------------------

PHONY += build-clean
PHONY += cross-base-clean
PHONY += cross-clean
PHONY += deps-clean
PHONY += host-clean
PHONY += host-bin-config-clean
PHONY += staging-clean
PHONY += target-clean
PHONY += ccache-clean
PHONY += rebuild-clean
PHONY += all-clean
PHONY += clean
PHONY += distclean
PHONY += clean-all
PHONY += %-clean
