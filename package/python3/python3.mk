################################################################################
#
# python3
#
################################################################################

PYTHON3_VERSION = 3.10.4
PYTHON3_DIR = Python-$(PYTHON3_VERSION)
PYTHON3_SOURCE = Python-$(PYTHON3_VERSION).tar.xz
PYTHON3_SITE = https://www.python.org/ftp/python/$(PYTHON3_VERSION)

# ------------------------------------------------------------------------------

HOST_PYTHON3_BINARY = $(HOST_DIR)/bin/python3

HOST_PYTHON3_LIB_DIR = lib/python$(basename $(HOST_PYTHON3_VERSION))
HOST_PYTHON3_INCLUDE_DIR = include/python$(basename $(HOST_PYTHON3_VERSION))
HOST_PYTHON3_SITEPACKAGES_DIR = $(HOST_PYTHON3_LIB_DIR)/site-packages

HOST_PYTHON3_DEPENDENCIES = host-expat host-zlib host-libffi

#HOST_PYTHON3_AUTORECONF = YES

# HOST_PYTHON3_AUTORECONF won't work
define HOST_PYTHON3_AUTOCONF
	$(CD) $(PKG_BUILD_DIR); \
		autoconf
endef
HOST_PYTHON3_POST_PATCH_HOOKS += HOST_PYTHON3_AUTOCONF

# Make sure that LD_LIBRARY_PATH overrides -rpath.
# This is needed because libpython may be installed at the same time that
# python is called.
# Make python believe we don't have 'hg', so that it doesn't try to
# communicate over the network during the build.
HOST_PYTHON3_CONF_ENV += \
	LDFLAGS="$(HOST_LDFLAGS) -Wl,--enable-new-dtags" \
	ac_cv_prog_HAS_HG=/bin/false

#HOST_PYTHON3_CONF_ENV = \
#	OPT="$(HOST_CFLAGS)"

HOST_PYTHON3_CONF_OPTS += \
	--without-ensurepip \
	--without-cxx-main \
	--disable-sqlite3 \
	--disable-tk \
	--with-expat=system \
	--disable-curses \
	--disable-codecs-cjk \
	--disable-nis \
	--enable-unicodedata \
	--disable-test-modules \
	--disable-idle3 \
	--disable-ossaudiodev

HOST_PYTHON3_CONF_OPTS += --disable-uuid
HOST_PYTHON3_CONF_OPTS += --disable-bzip2
HOST_PYTHON3_CONF_OPTS += --disable-openssl

define HOST_PYTHON3_INSTALL_SYMLINK
	ln -fs python3 $(HOST_DIR)/bin/python
	ln -fs python3-config $(HOST_DIR)/bin/python-config
endef
HOST_PYTHON3_HOST_FINALIZE_HOOKS += HOST_PYTHON3_INSTALL_SYMLINK

host-python3: | $(HOST_DIR)
	$(call host-autotools-package)
