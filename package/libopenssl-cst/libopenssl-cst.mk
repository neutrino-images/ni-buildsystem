################################################################################
#
# libopenssl-cst
#
################################################################################

LIBOPENSSL_CST_VERSION = 1.0.2u
LIBOPENSSL_CST_DIR = openssl-$(LIBOPENSSL_CST_VERSION)
LIBOPENSSL_CST_SOURCE = openssl-$(LIBOPENSSL_CST_VERSION).tar.gz
LIBOPENSSL_CST_SITE = $(GITHUB)/openssl/openssl/releases/download/OpenSSL_$(subst .,_,$(LIBOPENSSL_CST_VERSION))

LIBOPENSSL_CST_CONF_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

LIBOPENSSL_CST_CONF_OPTS += \
	linux-armv4 \
	shared \
	threads \
	no-hw \
	no-engine \
	no-sse2 \
	no-tests \
	no-fuzz-afl \
	no-fuzz-libfuzzer \
	no-perlasm

LIBOPENSSL_CST_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

define LIBOPENSSL_CST_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		./Configure $($(PKG)_CONF_OPTS)
endef

define LIBOPENSSL_CST_PATCH_MAKEFILE
	$(SED) 's| build_tests||' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' $(PKG_BUILD_DIR)/Makefile
endef
LIBOPENSSL_CST_POST_CONFIGURE_HOOKS += LIBOPENSSL_CST_PATCH_MAKEFILE

define LIBOPENSSL_CST_MAKE_DEPEND
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_MAKE) depend
endef
LIBOPENSSL_CST_PRE_BUILD_HOOKS += LIBOPENSSL_CST_MAKE_DEPEND

LIBOPENSSL_CST_MAKE_INSTALL_ARGS = \
	install_sw

LIBOPENSSL_CST_MAKE_INSTALL_OPTS = \
	INSTALL_PREFIX=$(TARGET_DIR)

define LIBOPENSSL_CST_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/{c_rehash,openssl}
	$(TARGET_RM) $(TARGET_libdir)/engines
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*,tsget*}
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/openssl.cnf
endef
LIBOPENSSL_CST_TARGET_FINALIZE_HOOKS += LIBOPENSSL_CST_TARGET_CLEANUP

define LIBOPENSSL_CST_FIXUP_PERMISSIONS
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
endef
LIBOPENSSL_CST_TARGET_FINALIZE_HOOKS += LIBOPENSSL_CST_FIXUP_PERMISSIONS

LIBOPENSSL_CST_SO_ENDING = 1.0.0
LIBOPENSSL_CST_COMPATIBILITY_VERSIONS = 0.9.7 0.9.8 1.0.2

define LIBOPENSSL_CST_COMPATIBILITY_LINKS
	$(foreach v,$(LIBOPENSSL_CST_COMPATIBILITY_VERSIONS),\
		ln -sf libcrypto.so.$(LIBOPENSSL_CST_SO_ENDING) $(TARGET_libdir)/libcrypto.so.$(v)$(sep))
	$(foreach v,$(LIBOPENSSL_CST_COMPATIBILITY_VERSIONS),\
		ln -sf libssl.so.$(LIBOPENSSL_CST_SO_ENDING) $(TARGET_libdir)/libssl.so.$(v)$(sep))
endef
LIBOPENSSL_CST_TARGET_FINALIZE_HOOKS += LIBOPENSSL_CST_COMPATIBILITY_LINKS

libopenssl-cst: | $(TARGET_DIR)
	$(call autotools-package)
