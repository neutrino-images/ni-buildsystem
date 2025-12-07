################################################################################
#
# coreutils
#
################################################################################

COREUTILS_VERSION = $(if $(filter $(BOXTYPE),coolstream),9.2,9.9)
COREUTILS_DIR = coreutils-$(COREUTILS_VERSION)
COREUTILS_SOURCE = coreutils-$(COREUTILS_VERSION).tar.xz
COREUTILS_SITE = $(GNU_MIRROR)/coreutils

#COREUTILS_AUTORECONF = YES

COREUTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--bindir=$(base_bindir).$(@F) \
	--libexecdir=$(REMOVE_libexecdir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-xattr \
	--disable-libcap \
	--disable-acl \
	--disable-rpath \
	--disable-year2038 \
	--disable-single-binary \
	--without-gmp \
	--without-selinux

COREUTILS_BINARIES = touch

COREUTILS_MAKE = \
	$(MAKE1)

define COREUTILS_INSTALL_BINARIES
	$(foreach binary,$($(PKG)_BINARIES),\
		rm -f $(TARGET_base_bindir)/$(binary); \
		$(INSTALL_EXEC) -D $(TARGET_base_bindir).$(@F)/$(binary) $(TARGET_base_bindir)/$(binary); \
		rm -f $(TARGET_base_bindir).$(@F)/$(binary)$(sep) \
	)
	$(TARGET_RM) $(TARGET_base_bindir).$(@F)
endef
COREUTILS_TARGET_FINALIZE_HOOKS += COREUTILS_INSTALL_BINARIES

coreutils: | $(TARGET_DIR)
	$(call autotools-package)
