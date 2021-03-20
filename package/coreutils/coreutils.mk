################################################################################
#
# coreutils
#
################################################################################

COREUTILS_VERSION = 8.30
COREUTILS_DIR = coreutils-$(COREUTILS_VERSION)
COREUTILS_SOURCE = coreutils-$(COREUTILS_VERSION).tar.xz
COREUTILS_SITE = $(GNU_MIRROR)/coreutils

COREUTILS_AUTORECONF = YES

COREUTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--bindir=$(base_bindir).$(@F) \
	--libexecdir=$(REMOVE_libexecdir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-silent-rules \
	--disable-xattr \
	--disable-libcap \
	--disable-acl \
	--without-gmp \
	--without-selinux

COREUTILS_BINARIES = touch

define COREUTILS_INSTALL_BINARIES
	for bin in $(COREUTILS_BINARIES); do \
		rm -f $(TARGET_base_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_base_bindir).$(@F)/$$bin $(TARGET_base_bindir)/$$bin; \
	done
	rm -r $(TARGET_base_bindir).$(@F)
endef
COREUTILS_TARGET_FINALIZE_HOOKS += COREUTILS_INSTALL_BINARIES

coreutils: | $(TARGET_DIR)
	$(call autotools-package)
