################################################################################
#
# binutils
#
################################################################################

BINUTILS_VERSION = 2.35
BINUTILS_DIR = binutils-$(BINUTILS_VERSION)
BINUTILS_SOURCE = binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_SITE = $(GNU_MIRROR)/binutils

$(DL_DIR)/$(BINUTILS_SOURCE):
	$(download) $(BINUTILS_SITE)/$(BINUTILS_SOURCE)

BINUTILS_CONF_OPTS = \
	--disable-multilib \
	--disable-werror \
	--disable-plugins \
	--enable-build-warnings=no \
	--disable-sim \
	--disable-gdb 

BINUTILS_BINARIES = objdump objcopy

binutils: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
	for bin in $($(PKG)_BINARIES); do \
		$(INSTALL_EXEC) $(BUILD_DIR)/$(PKG_DIR)/binutils/$$bin $(TARGET_bindir)/; \
	done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
