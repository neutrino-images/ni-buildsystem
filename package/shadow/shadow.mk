################################################################################
#
# shadow
#
################################################################################

SHADOW_VERSION = 4.8.1
SHADOW_DIR = shadow-$(SHADOW_VERSION)
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_SITE = https://github.com/shadow-maint/shadow/releases/download/$(SHADOW_VERSION)

SHADOW_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--datarootdir=$(REMOVE_base_datarootdir)

define SHADOW_PATCH_USERADD
	$(SED) 's|SHELL=.*|SHELL=/bin/sh|' $(TARGET_sysconfdir)/default/useradd
endef
SHADOW_TARGET_FINALIZE_HOOKS += SHADOW_PATCH_USERADD

shadow: | $(TARGET_DIR)
	$(call autotools-package)
