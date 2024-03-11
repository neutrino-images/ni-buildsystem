#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR) \
$(HOST_DEPS_DIR):
	$(INSTALL) -d $(@)

# -----------------------------------------------------------------------------

HOST_TOOLS_COMPRESSION = host-tar host-bzip2 host-gzip host-zip
HOST_TOOLS_ESSENTIALS = host-findutils host-grep host-sed host-patch host-gawk

host-tools: $(BUILD_DIR) $(HOST_DIR) $(HOST_DEPS_DIR) \
	$(HOST_TOOLS_COMPRESSION) \
	$(HOST_TOOLS_ESSENTIALS) \
	host-cmake \
	host-pkgconf \
	$(PKG_CONFIG) \
	host-ncurses \
	host-m4 \
	host-kmod \
	host-bc \
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

host-tools.renew: host-clean host-tools clean

# -----------------------------------------------------------------------------

PKG_CONFIG_DEPENDENCIES = host-pkgconf

$(PKG_CONFIG): $(PKG_CONFIG_DEPENDENCIES) | $(HOST_DIR)
	ln -sf $(HOST_PKG_CONFIG_BINARY) $(@)

# -----------------------------------------------------------------------------

PHONY += host-tools
