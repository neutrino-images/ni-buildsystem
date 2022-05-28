################################################################################
#
# shadow
#
################################################################################

SHADOW_VERSION = 4.11.1
SHADOW_DIR = shadow-$(SHADOW_VERSION)
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_SITE = https://github.com/shadow-maint/shadow/releases/download/v$(SHADOW_VERSION)

SHADOW_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--datarootdir=$(REMOVE_base_datarootdir)

shadow: | $(TARGET_DIR)
	$(call autotools-package)
