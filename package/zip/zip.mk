################################################################################
#
# zip
#
################################################################################

# The version is really 3.0, but the tarball is named zip30.tgz
ZIP_VERSION = $(subst .,,3.0)
ZIP_DIR = zip$(ZIP_VERSION)
ZIP_SOURCE = zip$(ZIP_VERSION).tgz
ZIP_SITE = ftp://ftp.info-zip.org/pub/infozip/src

# Infozip's default CFLAGS.
ZIP_CFLAGS = -I. -DUNIX

# Disable the support of 16-bit UIDs/GIDs, the test in unix/configure was
# removed since it can't work for cross-compilation.
ZIP_CFLAGS += -DUIDGID_NOT_16BIT

# -----------------------------------------------------------------------------

HOST_ZIP_DEPENDENCIES = host-bzip2

define HOST_ZIP_BUILD_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_MAKE_ENV) $(MAKE) $(HOST_CONFIGURE_ENV) \
		CFLAGS="$(HOST_CFLAGS) $(ZIP_CFLAGS)" \
		AS="$(HOSTCC) -c" \
		-f unix/Makefile generic
endef

define HOST_ZIP_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_MAKE_ENV) $(MAKE) $(HOST_CONFIGURE_ENV) \
		prefix=$(HOST_DIR) \
		MANDIR=$(HOST_DIR)/share/man/man1 \
		-f unix/Makefile install
endef

host-zip: | $(HOST_DIR)
	$(call host-generic-package)
