#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR):
	$(INSTALL) -d $(HOST_DIR)
	$(INSTALL) -d $(HOST_DIR)/bin
	$(INSTALL) -d $(HOST_DEPS_DIR)

# -----------------------------------------------------------------------------

host-tools: $(BUILD_DIR) $(HOST_DIR) \
	host-pkgconf \
	$(PKG_CONFIG) \
	host-mtd-utils \
	host-u-boot \
	host-zic \
	host-parted \
	host-dosfstools \
	host-mtools \
	host-e2fsprogs \
	host-qrencode \
	host-lua \
	host-luarocks \
	host-ccache

# -----------------------------------------------------------------------------

PKG_CONFIG_DEPENDENCIES = host-pkgconf

$(PKG_CONFIG): $(PKG_CONFIG_DEPENDENCIES) | $(HOST_DIR)
	ln -sf $(HOST_PKG_CONFIG) $(@)

# -----------------------------------------------------------------------------

HOST_MESON_VERSION = 0.56.0
HOST_MESON_DIR = meson-$(HOST_MESON_VERSION)
HOST_MESON_SOURCE = meson-$(HOST_MESON_VERSION).tar.gz
HOST_MESON_SITE = https://github.com/mesonbuild/meson/releases/download/$(HOST_MESON_VERSION)

$(DL_DIR)/$(HOST_MESON_SOURCE):
	$(download) $(HOST_MESON_SITE)/$(HOST_MESON_SOURCE)

HOST_MESON_DEPENDENCIES = host-ninja host-python3 host-python3-setuptools

HOST_MESON = $(HOST_DIR)/bin/meson

host-meson: $(HOST_MESON_DEPENDENCIES) $(DL_DIR)/$(HOST_MESON_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(HOST_MESON_DIR)
	$(UNTAR)/$(HOST_MESON_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(HOST_MESON_DIR); \
		$(HOST_PYTHON_BUILD); \
		$(HOST_PYTHON_INSTALL)
	$(REMOVE)/$(HOST_MESON_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_NINJA_VERSION = 1.10.2
HOST_NINJA_DIR = ninja-$(HOST_NINJA_VERSION)
HOST_NINJA_SOURCE = ninja-$(HOST_NINJA_VERSION).tar.gz
HOST_NINJA_SITE = $(call github,ninja-build,ninja,v$(HOST_NINJA_VERSION))

$(DL_DIR)/$(HOST_NINJA_SOURCE):
	$(download) $(HOST_NINJA_SITE)/$(HOST_NINJA_SOURCE)

HOST_NINJA = $(HOST_DIR)/bin/ninja

host-ninja: $(DL_DIR)/$(HOST_NINJA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CMAKE); \
		$(MAKE)
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/ninja $(HOST_NINJA)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PYTHON3_VERSION = 3.9.0
HOST_PYTHON3_DIR = Python-$(HOST_PYTHON3_VERSION)
HOST_PYTHON3_SOURCE = Python-$(HOST_PYTHON3_VERSION).tar.xz
HOST_PYTHON3_SITE = https://www.python.org/ftp/python/$(HOST_PYTHON3_VERSION)

HOST_PYTHON3_BASE_DIR = lib/python$(basename $(HOST_PYTHON3_VERSION))
HOST_PYTHON3_INCLUDE_DIR = include/python$(basename $(HOST_PYTHON3_VERSION))

$(DL_DIR)/$(HOST_PYTHON3_SOURCE):
	$(download) $(HOST_PYTHON3_SITE)/$(HOST_PYTHON3_SOURCE)

HOST_PYTHON3_DEPENDENCIES = host-expat host-libffi

HOST_PYTHON3_CONF_ENV = \
	OPT="$(HOST_CFLAGS)"

HOST_PYTHON3_CONF_OPTS = \
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

host-python3: $(HOST_PYTHON3_DEPENDENCIES) $(DL_DIR)/$(HOST_PYTHON3_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	#$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		autoconf; \
		$(HOST_CONFIGURE);\
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_PYTHON3_SETUPTOOLS_VERSION = 44.0.0
HOST_PYTHON3_SETUPTOOLS_DIR = setuptools-$(HOST_PYTHON3_SETUPTOOLS_VERSION)
HOST_PYTHON3_SETUPTOOLS_SOURCE = setuptools-$(HOST_PYTHON3_SETUPTOOLS_VERSION).zip
HOST_PYTHON3_SETUPTOOLS_SITE = https://files.pythonhosted.org/packages/b0/f3/44da7482ac6da3f36f68e253cb04de37365b3dba9036a3c70773b778b485

$(DL_DIR)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE):
	$(download) $(HOST_PYTHON3_SETUPTOOLS_SITE)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE)

HOST_PYTHON3_SETUPTOOLS_DEPENDENCIES = host-python3

host-python3-setuptools: $(HOST_PYTHON3_SETUPTOOLS_DEPENDENCIES) $(DL_DIR)/$(HOST_PYTHON3_SETUPTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNZIP)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_PYTHON_BUILD); \
		$(HOST_PYTHON_INSTALL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

# helper target to create ccache links

ifndef CCACHE
CCACHE := ccache
endif
CCACHE := $(shell which $(CCACHE) || type -p $(CCACHE) || echo ccache)

CCACHE_DIR = $(HOME)/.ccache-$(call LOWERCASE,$(TARGET_VENDOR))-$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)
export CCACHE_DIR

host-ccache: find-ccache $(CCACHE) | $(HOST_DIR) \
	$(HOST_DIR)/bin/cc \
	$(HOST_DIR)/bin/gcc \
	$(HOST_DIR)/bin/g++ \
	$(HOST_DIR)/bin/$(TARGET_CC) \
	$(HOST_DIR)/bin/$(TARGET_CXX)

$(HOST_DIR)/bin/cc \
$(HOST_DIR)/bin/gcc \
$(HOST_DIR)/bin/g++ \
$(HOST_DIR)/bin/$(TARGET_CC) \
$(HOST_DIR)/bin/$(TARGET_CXX):
	ln -sf $(CCACHE) $(@)

# -----------------------------------------------------------------------------

PHONY += host-tools
PHONY += pkg-config-preqs
PHONY += host-ccache
