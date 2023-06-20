#
# makefile to build all needed host-binaries
#
# -----------------------------------------------------------------------------

$(HOST_DIR):
	$(INSTALL) -d $(HOST_DIR)
	$(INSTALL) -d $(HOST_DEPS_DIR)

# -----------------------------------------------------------------------------

host-tools: $(BUILD_DIR) $(HOST_DIR) \
	host-pkgconf \
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

PHONY += host-tools
