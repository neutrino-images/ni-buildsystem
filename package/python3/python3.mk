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

PYTHON3_DEPENDENCIES = libffi

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
	--without-ensurepip \
	--without-cxx-main \
	--with-build-python=$(HOST_PYTHON_BINARY) \
	--with-system-ffi \
	--disable-pydoc \
	--disable-test-modules \
	--disable-tk \
	--disable-nis \
	--disable-idle3 \
	--disable-pyc-build

PYTHON3_CONF_OPTS += --disable-lib2to3
PYTHON3_CONF_OPTS += --disable-berkeleydb
PYTHON3_CONF_OPTS += --disable-readline

PYTHON3_DEPENDENCIES += ncurses

PYTHON3_CONF_OPTS += --with-libmpdec=none

PYTHON3_DEPENDENCIES += expat
PYTHON3_CONF_OPTS += --with-expat=system

PYTHON3_DEPENDENCIES += sqlite

PYTHON3_DEPENDENCIES += openssl
PYTHON3_CONF_OPTS += --with-openssl=$(TARGET_prefix)

PYTHON3_CONF_OPTS += --disable-codecs-cjk
PYTHON3_CONF_OPTS += --enable-unicodedata

# Disable auto-detection of uuid.h (util-linux)
# which would add _uuid module support, instead
# default to the pure python implementation
PYTHON3_CONF_OPTS += --disable-uuid

PYTHON3_DEPENDENCIES += bzip2
PYTHON3_DEPENDENCIES += xz
PYTHON3_DEPENDENCIES += zlib

PYTHON3_CONF_OPTS += --disable-ossaudiodev

#
# Remove useless files. In the config/ directory, only the Makefile
# and the pyconfig.h files are needed at runtime.
#
define PYTHON3_REMOVE_USELESS_FILES
	rm -f $(TARGET_bindir)/python3-config
	rm -f $(TARGET_bindir)/python$(PYTHON3_VERSION_MAJOR)-config
	rm -f $(TARGET_bindir)/python$(PYTHON3_VERSION_MAJOR)m-config
	rm -f $(TARGET_bindir)/smtpd.py.*
	rm -f $(PYTHON3_LIB_DIR)/distutils/command/wininst*.exe
	for i in `find $(PYTHON3_LIB_DIR)/config-$(PYTHON3_VERSION_MAJOR)-*/ \
		-type f -not -name Makefile` ; do \
		rm -f $$i ; \
	done
	rm -rf $(PYTHON3_LIB_DIR)/__pycache__
	rm -rf $(PYTHON3_LIB_DIR)/lib-dynload/sysconfigdata/__pycache__
	rm -rf $(PYTHON3_LIB_DIR)/collections/__pycache__
	rm -rf $(PYTHON3_LIB_DIR)/importlib/__pycache__
endef
PYTHON3_POST_INSTALL_HOOKS += PYTHON3_REMOVE_USELESS_FILES

#
# Make sure libpython gets stripped out on target
#
define PYTHON3_ENSURE_LIBPYTHON_STRIPPED
	chmod u+w $(TARGET_libdir)/libpython$(PYTHON3_VERSION_MAJOR)*.so
endef
PYTHON3_POST_INSTALL_HOOKS += PYTHON3_ENSURE_LIBPYTHON_STRIPPED

define PYTHON3_FIX_TIME
	find $(PYTHON3_LIB_DIR) -name '*.py' -print0 | \
		xargs -0 --no-run-if-empty touch -d @$(SOURCE_DATE_EPOCH)
endef

define PYTHON3_CREATE_PYC_FILES
	$(PYTHON3_FIX_TIME)
	PYTHONPATH="$(PYTHON3_PATH)" \
	$(HOST_PYTHON_BINARY) \
		$(PKG_BUILD_DIR)/Lib/compileall.py \
		$(if $(VERBOSE),,-q) \
		-s $(TARGET_DIR) \
		-p / \
		$(PYTHON3_LIB_DIR)
endef
PYTHON3_POST_INSTALL_HOOKS += PYTHON3_CREATE_PYC_FILES

define PYTHON3_REMOVE_OPTIMIZED_PYC_FILES
	find $(PYTHON3_LIB_DIR) -name '*.opt-1.pyc' -print0 -o -name '*.opt-2.pyc' -print0 | \
		xargs -0 --no-run-if-empty rm -f
endef
PYTHON3_POST_INSTALL_HOOKS += PYTHON3_REMOVE_OPTIMIZED_PYC_FILES

define PYTHON3_INSTALL_SYMLINK
	ln -sf python3 $(TARGET_bindir)/python
endef
PYTHON3_TARGET_FINALIZE_HOOKS += PYTHON3_INSTALL_SYMLINK

python3: | $(TARGET_DIR)
	$(call autotools-package)

# ------------------------------------------------------------------------------

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
	--disable-sqlite3 \
	--disable-tk \
	--with-expat=system \
	--disable-curses \
	--disable-codecs-cjk \
	--disable-nis \
	--enable-unicodedata \
	--disable-test-modules \
	--disable-idle3 \
	--disable-uuid \
	--disable-ossaudiodev

HOST_PYTHON3_CONF_OPTS += --disable-bzip2
HOST_PYTHON3_CONF_OPTS += --disable-openssl

define HOST_PYTHON3_INSTALL_SYMLINK
	ln -sf python3 $(HOST_DIR)/bin/python
	ln -sf python3-config $(HOST_DIR)/bin/python-config
endef
HOST_PYTHON3_HOST_FINALIZE_HOOKS += HOST_PYTHON3_INSTALL_SYMLINK

host-python3: | $(HOST_DIR)
	$(call host-autotools-package)
