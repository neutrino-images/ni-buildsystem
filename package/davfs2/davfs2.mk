################################################################################
#
# davfs2
#
################################################################################

DAVFS2_VERSION = 1.7.3
DAVFS2_DIR = davfs2-$(DAVFS2_VERSION)
DAVFS2_SOURCE = davfs2-$(DAVFS2_VERSION).tar.gz
DAVFS2_SITE = http://download.savannah.nongnu.org/releases/davfs2

DAVFS2_DEPENDENCIES = libiconv neon

DAVFS2_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--docdir=$(REMOVE_docdir) \
	--localedir=$(REMOVE_localedir)

DAVFS2_CONF_ENV = \
	ac_cv_path_NEON_CONFIG=$(HOST_DIR)/bin/neon-config

define DAVFS2_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_datarootdir)/davfs2/,davfs2.conf secrets)
endef
DAVFS2_TARGET_FINALIZE_HOOKS += DAVFS2_TARGET_CLEANUP

davfs2: | $(TARGET_DIR)
	$(call autotools-package)
