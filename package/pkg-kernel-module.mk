################################################################################
#
# Kernel modules
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

define KERNEL_MODULE_BUILD
	@$(call MESSAGE,"Building kernel module")
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_MAKE_ENV) $($(PKG)_MAKE_ENV) \
		$(MAKE) \
			$($(PKG)_MAKE_OPTS) $(KERNEL_MAKE_VARS)
endef

# -----------------------------------------------------------------------------

define kernel-module
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
