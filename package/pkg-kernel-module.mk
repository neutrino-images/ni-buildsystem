################################################################################
#
# kernel module infrastructure for building Linux kernel modules
#
################################################################################

# while the kernel is built for the target, the build may need various
# host libraries depending on config (and version), so use
# HOST_MAKE_ENV here. In particular, this ensures that our
# host-pkgconf will look for host libraries and not target ones.
LINUX_MAKE_ENV = \
	$(HOST_MAKE_ENV)

KERNEL_MAKE_VARS = \
	PATH=$(PATH) \
	ARCH=$(TARGET_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	LOCALVERSION= \
	O=$(KERNEL_OBJ_DIR)

# Compatibility variables
KERNEL_MAKE_VARS += \
	KVER=$(KERNEL_VERSION) \
	KSRC=$(BUILD_DIR)/$(KERNEL_DIR)

KERNEL_MODULE_MAKE_VARS = \
	$(KERNEL_MAKE_VARS) \
	INSTALL_MOD_PATH=$(TARGET_DIR) \
	INSTALL_HDR_PATH=$(TARGET_DIR)

define KERNEL_MODULE_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(LINUX_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$($(PKG)_MAKE) $($(PKG)_MAKE_ARGS) \
			$(KERNEL_MODULE_MAKE_VARS) \
			$($(PKG)_MAKE_OPTS)
endef

define KERNEL_MODULE_BUILD
	@$(call MESSAGE,"Building $(pkgname) kernel module(s)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define KERNEL_MODULE_INSTALL_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(LINUX_MAKE_ENV) $($(PKG)_MAKE_INSTALL_ENV) \
		$($(PKG)_MAKE_INSTALL) $($(PKG)_MAKE_INSTALL_ARGS) \
			$(KERNEL_MODULE_MAKE_VARS) \
			$($(PKG)_MAKE_INSTALL_OPTS)
endef

define KERNEL_MODULE_INSTALL
	@$(call MESSAGE,"Installing $(pkgname) kernel module(s)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define kernel-module
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call KERNEL_MODULE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call KERNEL_MODULE_INSTALL))
	$(Q)$(call LINUX_RUN_DEPMOD)
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define LINUX_RUN_DEPMOD
	@$(call MESSAGE,"Running depmod")
	if test -d $(TARGET_modulesdir) && grep -q "CONFIG_MODULES=y" $(KERNEL_OBJ_DIR)/.config; then \
		$(HOST_DEPMOD) -a -b $(TARGET_DIR) $(KERNEL_VERSION); \
	fi
endef
