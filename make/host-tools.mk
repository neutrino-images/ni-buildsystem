#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR):
	$(INSTALL) -d $(HOST_DIR)
	$(INSTALL) -d $(HOST_DEPS_DIR)

# -----------------------------------------------------------------------------

host-tools: $(BUILD_DIR) $(HOST_DIR) \
	host-cmake \
	host-pkgconf \
	$(PKG_CONFIG) \
	host-m4 \
	host-bison \
	host-flex \
	host-gawk \
	host-kmod \
	host-mtd-utils \
	host-u-boot \
	host-zic \
	host-parted \
	host-python3 \
	host-meson \
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
	ln -sf $(HOST_PKG_CONFIG_BINARY) $(@)

# -----------------------------------------------------------------------------

PHONY += $(HOST_DIR)
PHONY += host-tools
