################################################################################
#
# openssl
#
################################################################################

OPENSSL_VERSION = $(if $(filter $(BOXTYPE),coolstream),1.0.2u,1.1.1o)
OPENSSL_DIR = openssl-$(OPENSSL_VERSION)
OPENSSL_SOURCE = openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE = https://www.openssl.org/source

ifeq ($(TARGET_ARCH),arm)
  OPENSSL_TARGET_ARCH = linux-armv4
else ifeq ($(TARGET_ARCH),mips)
  OPENSSL_TARGET_ARCH = linux-generic32
endif

OPENSSL_CONF_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

OPENSSL_CONF_OPTS += \
	$(OPENSSL_TARGET_ARCH) \
	shared \
	threads \
	no-hw \
	no-engine \
	no-sse2 \
	no-tests \
	no-fuzz-afl \
	no-fuzz-libfuzzer

ifeq ($(BOXTYPE),coolstream)
OPENSSL_CONF_OPTS += \
	no-perlasm
endif

OPENSSL_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

define OPENSSL_CONFIGURE_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		./Configure $($(PKG)_CONF_OPTS)
endef

define OPENSSL_PATCH_MAKEFILE
	$(SED) 's| build_tests||' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' $(PKG_BUILD_DIR)/Makefile
endef
OPENSSL_POST_CONFIGURE_HOOKS += OPENSSL_PATCH_MAKEFILE

define OPENSSL_MAKE_DEPEND
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_MAKE) depend
endef
OPENSSL_PRE_BUILD_HOOKS += OPENSSL_MAKE_DEPEND

OPENSSL_MAKE_INSTALL_ARGS = \
	install_sw

ifeq ($(BOXTYPE),coolstream)
OPENSSL_MAKE_INSTALL_OPTS = \
	INSTALL_PREFIX=$(TARGET_DIR)
else
OPENSSL_MAKE_INSTALL_ARGS += \
	install_ssldirs
endif

define OPENSSL_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libdir)/engines-1.1
	$(TARGET_RM) $(TARGET_bindir)/c_rehash
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/ct_log_list.cnf*
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.pl,tsget*}
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/openssl.cnf.dist
endef
OPENSSL_TARGET_FINALIZE_HOOKS += OPENSSL_TARGET_CLEANUP

ifeq ($(BOXTYPE),coolstream)
define OPENSSL_TARGET_CLEANUP_COOLSTREAM
	$(TARGET_RM) $(TARGET_libdir)/engines
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*}
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/openssl.cnf
	$(TARGET_RM) $(TARGET_bindir)/openssl
endef
OPENSSL_TARGET_FINALIZE_HOOKS += OPENSSL_TARGET_CLEANUP_COOLSTREAM

define OPENSSL_FIXUP_PERMISSIONS
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
endef
OPENSSL_TARGET_FINALIZE_HOOKS += OPENSSL_FIXUP_PERMISSIONS
endif

ifeq ($(BOXTYPE),coolstream)
OPENSSL_SO_ENDING = 1.0.0
OPENSSL_COMPATIBILITY_VERSIONS = 0.9.7 0.9.8 1.0.2
else
OPENSSL_SO_ENDING = 1.1
OPENSSL_COMPATIBILITY_VERSIONS = 0.9.7 0.9.8 1.0.0 1.0.2 1.1.0
endif

define OPENSSL_COMPATIBILITY_LINKS
	$(foreach v,$(OPENSSL_COMPATIBILITY_VERSIONS),\
		ln -sf libcrypto.so.$(OPENSSL_SO_ENDING) $(TARGET_libdir)/libcrypto.so.$(v)$(sep))
	$(foreach v,$(OPENSSL_COMPATIBILITY_VERSIONS),\
		ln -sf libssl.so.$(OPENSSL_SO_ENDING) $(TARGET_libdir)/libssl.so.$(v)$(sep))
endef
OPENSSL_TARGET_FINALIZE_HOOKS += OPENSSL_COMPATIBILITY_LINKS

openssl: | $(TARGET_DIR)
	$(call autotools-package)
