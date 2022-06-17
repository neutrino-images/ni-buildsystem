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
