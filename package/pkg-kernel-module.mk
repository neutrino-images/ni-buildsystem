################################################################################
#
# kernel module infrastructure for building Linux kernel modules
#
################################################################################

KERNEL_MAKE_VARS = \
	ARCH=$(TARGET_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	INSTALL_MOD_PATH=$(KERNEL_MODULES_DIR) \
	INSTALL_HDR_PATH=$(KERNEL_HEADERS_DIR) \
	LOCALVERSION= \
	O=$(KERNEL_OBJ_DIR)

# Compatibility variables
KERNEL_MAKE_VARS += \
	KVER=$(KERNEL_VERSION) \
	KSRC=$(BUILD_DIR)/$(KERNEL_DIR)

define KERNEL_MODULE_BUILD_CMDS_DEFAULT
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) \
			$($(PKG)_MAKE_OPTS) $(KERNEL_MAKE_VARS)
endef

define KERNEL_MODULE_BUILD
	@$(call MESSAGE,"Building $(pkgname) kernel module")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define kernel-module
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(call KERNEL_MODULE_BUILD)
	$(call LINUX_RUN_DEPMOD)
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define LINUX_RUN_DEPMOD
	@$(call MESSAGE,"Running depmod")
	if test -d $(TARGET_modulesdir) && grep -q "CONFIG_MODULES=y" $(KERNEL_OBJ_DIR)/.config; then \
		PATH=$(PATH):/sbin:/usr/sbin depmod -a -b $(TARGET_DIR) $(KERNEL_VERSION); \
	fi
endef
