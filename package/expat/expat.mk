################################################################################
#
# expat
#
################################################################################

EXPAT_VERSION = 2.5.0
EXPAT_DIR = expat-$(EXPAT_VERSION)
EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.bz2
EXPAT_SITE = https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$(EXPAT_VERSION))

EXPAT_AUTORECONF = YES

EXPAT_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--without-docbook \
	--without-examples \
	--without-tests \
	--without-xmlwf

define EXPAT_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libdir)/cmake
endef
EXPAT_TARGET_FINALIZE_HOOKS += EXPAT_TARGET_CLEANUP

expat: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_EXPAT_CONF_OPTS = \
	--without-docbook

host-expat: | $(HOST_DIR)
	$(call host-autotools-package)
