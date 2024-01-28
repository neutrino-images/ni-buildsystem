################################################################################
#
# python3
#
################################################################################

PYTHON3_VERSION_MAJOR = 3.11
PYTHON3_VERSION = $(PYTHON3_VERSION_MAJOR).5
PYTHON3_DIR = Python-$(PYTHON3_VERSION)
PYTHON3_SOURCE = Python-$(PYTHON3_VERSION).tar.xz
PYTHON3_SITE = https://www.python.org/ftp/python/$(PYTHON3_VERSION)

PYTHON3_DEPENDENCIES = libffi ncurses sqlite bzip2 xz zlib expat openssl

# no cleanup
PYTHON3_KEEP_BUILD_DIR = YES

#PYTHON3_AUTORECONF = YES

# PYTHON3_AUTORECONF won't work
define PYTHON3_AUTOCONF
	$(CD) $(PKG_BUILD_DIR); \
		autoconf
endef
PYTHON3_PRE_CONFIGURE_HOOKS += PYTHON3_AUTOCONF

PYTHON3_CONF_ENV = \
	ac_cv_have_long_long_format=yes \
	ac_cv_file__dev_ptmx=yes \
	ac_cv_file__dev_ptc=yes \
	ac_cv_working_tzset=yes

# Make python believe we don't have 'hg', so that it doesn't try to
# communicate over the network during the build.
PYTHON3_CONF_ENV += \
	ac_cv_prog_HAS_HG=/bin/false

# GCC is always compliant with IEEE754
ifeq ($(TARGET_ENDIAN),"little")
PYTHON3_CONF_ENV += \
	ac_cv_little_endian_double=yes
else
PYTHON3_CONF_ENV += \
	ac_cv_big_endian_double=yes
endif

# uClibc is known to have a broken wcsftime() implementation, so tell
# Python 3 to fall back to strftime() instead.
ifeq ($(BOXTYPE),coolstream)
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))
PYTHON3_CONF_ENV += \
	ac_cv_func_wcsftime=no
endif
endif

PYTHON3_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--with-build-python=$(HOST_PYTHON_BINARY) \
	--with-expat=system \
	--with-libmpdec=none \
	--with-openssl=$(TARGET_prefix) \
	--with-system-ffi \
	--without-cxx-main \
	--without-ensurepip \
	--enable-optimizations \
	--enable-unicodedata \
	--disable-berkeleydb \
	--disable-codecs-cjk \
	--disable-idle3 \
	--disable-lib2to3 \
	--disable-nis \
	--disable-ossaudiodev \
	--disable-pydoc \
	--disable-readline \
	--disable-test-modules \
	--disable-tk

# Disable auto-detection of uuid.h (util-linux)
# which would add _uuid module support, instead
# default to the pure python implementation
PYTHON3_CONF_OPTS += --disable-uuid

#
# Make sure libpython gets stripped out on target
#
define PYTHON3_ENSURE_LIBPYTHON_STRIPPED
	chmod u+w $(TARGET_libdir)/libpython$(PYTHON3_VERSION_MAJOR)*.so
endef
PYTHON3_TARGET_FINALIZE_HOOKS += PYTHON3_ENSURE_LIBPYTHON_STRIPPED

define PYTHON3_INSTALL_SYMLINK
	ln -sf python3 $(TARGET_bindir)/python
endef
PYTHON3_TARGET_FINALIZE_HOOKS += PYTHON3_INSTALL_SYMLINK

define PYTHON3_INSTALL_PYTHON_VENV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/python-venv $(TARGET_bindir)/python-venv
endef
PYTHON3_TARGET_FINALIZE_HOOKS += PYTHON3_INSTALL_PYTHON_VENV

define PYTHON3_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/python3-config
	$(TARGET_RM) $(TARGET_bindir)/python$(PYTHON3_VERSION_MAJOR)-config
	$(TARGET_RM) $(TARGET_bindir)/smtpd.py.*
endef
PYTHON3_TARGET_FINALIZE_HOOKS += PYTHON3_TARGET_CLEANUP

python3: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_PYTHON3_DEPENDENCIES = host-expat host-zlib host-libffi

#HOST_PYTHON3_AUTORECONF = YES

# HOST_PYTHON3_AUTORECONF won't work
define HOST_PYTHON3_AUTOCONF
	$(CD) $(PKG_BUILD_DIR); \
		autoconf
endef
HOST_PYTHON3_PRE_CONFIGURE_HOOKS += HOST_PYTHON3_AUTOCONF

# Make sure that LD_LIBRARY_PATH overrides -rpath.
# This is needed because libpython may be installed at the same time that
# python is called.
HOST_PYTHON3_CONF_ENV = \
	LDFLAGS="$(HOST_LDFLAGS) -Wl,--enable-new-dtags"

# Make python believe we don't have 'hg', so that it doesn't try to
# communicate over the network during the build.
HOST_PYTHON3_CONF_ENV += \
	ac_cv_prog_HAS_HG=/bin/false

HOST_PYTHON3_CONF_OPTS += \
	--without-ensurepip \
	--without-cxx-main \
	--with-expat=system \
	--enable-unicodedata \
	--disable-bzip2 \
	--disable-codecs-cjk \
	--disable-curses \
	--disable-idle3 \
	--disable-nis \
	--disable-openssl \
	--disable-ossaudiodev \
	--disable-sqlite3 \
	--disable-test-modules \
	--disable-tk \
	--disable-uuid

define HOST_PYTHON3_INSTALL_SYMLINK
	ln -sf python3 $(HOST_DIR)/bin/python
	ln -sf python3-config $(HOST_DIR)/bin/python-config
endef
HOST_PYTHON3_HOST_FINALIZE_HOOKS += HOST_PYTHON3_INSTALL_SYMLINK

host-python3: | $(HOST_DIR)
	$(call host-autotools-package)
