################################################################################
#
# binutils
#
################################################################################

BINUTILS_VERSION = 2.35
BINUTILS_DIR = binutils-$(BINUTILS_VERSION)
BINUTILS_SOURCE = binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_SITE = $(GNU_MIRROR)/binutils

BINUTILS_CONF_OPTS = \
	--bindir=$(base_bindir).$(@F) \
	--datarootdir=$(REMOVE_datarootdir) \
	--libdir=$(REMOVE_libdir) \
	--includedir=$(REMOVE_includedir) \
	--disable-multilib \
	--disable-werror \
	--disable-plugins \
	--enable-build-warnings=no \
	--disable-sim \
	--disable-gdb 

BINUTILS_BINARIES = objdump objcopy

define BINUTILS_INSTALL_BINARIES
	$(foreach binary,$($(PKG)_BINARIES),\
		$(INSTALL_EXEC) $(TARGET_base_bindir).$(@F)/$(binary) $(TARGET_bindir)/; \
		rm -f $(TARGET_base_bindir).$(@F)/$(binary)$(sep) \
	)
	$(TARGET_RM) $(TARGET_base_bindir).$(@F)
endef
BINUTILS_TARGET_FINALIZE_HOOKS += BINUTILS_INSTALL_BINARIES

define BINUTILS_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_prefix)/$(TARGET)
endef
BINUTILS_TARGET_FINALIZE_HOOKS += BINUTILS_TARGET_CLEANUP

binutils: | $(TARGET_DIR)
	$(call autotools-package)
