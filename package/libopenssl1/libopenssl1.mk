################################################################################
#
# libopenssl1
#
################################################################################

LIBOPENSSL1_VERSION = 1.0.2u
LIBOPENSSL1_DIR = openssl-$(LIBOPENSSL1_VERSION)
LIBOPENSSL1_SOURCE = openssl-$(LIBOPENSSL1_VERSION).tar.gz
LIBOPENSSL1_SITE = $(GITHUB)/openssl/openssl/releases/download/OpenSSL_$(subst .,_,$(LIBOPENSSL1_VERSION))

LIBOPENSSL1_CONF_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

LIBOPENSSL1_CONF_OPTS += \
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

LIBOPENSSL1_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

define LIBOPENSSL1_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		./Configure $($(PKG)_CONF_OPTS)
endef

define LIBOPENSSL1_PATCH_MAKEFILE
	$(SED) 's| build_tests||' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' $(PKG_BUILD_DIR)/Makefile
endef
LIBOPENSSL1_POST_CONFIGURE_HOOKS += LIBOPENSSL1_PATCH_MAKEFILE

define LIBOPENSSL1_MAKE_DEPEND
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_MAKE) depend
endef
LIBOPENSSL1_PRE_BUILD_HOOKS += LIBOPENSSL1_MAKE_DEPEND

LIBOPENSSL1_MAKE_INSTALL_ARGS = \
	install_sw

LIBOPENSSL1_MAKE_INSTALL_OPTS = \
	INSTALL_PREFIX=$(TARGET_DIR)

define LIBOPENSSL1_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/{c_rehash,openssl}
	$(TARGET_RM) $(TARGET_libdir)/engines
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*,tsget*}
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/openssl.cnf
endef
LIBOPENSSL1_TARGET_FINALIZE_HOOKS += LIBOPENSSL1_TARGET_CLEANUP

define LIBOPENSSL1_FIXUP_PERMISSIONS
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
endef
LIBOPENSSL1_TARGET_FINALIZE_HOOKS += LIBOPENSSL1_FIXUP_PERMISSIONS

LIBOPENSSL1_SO_ENDING = 1.0.0
LIBOPENSSL1_COMPATIBILITY_VERSIONS = 0.9.7 0.9.8 1.0.2

define LIBOPENSSL1_COMPATIBILITY_LINKS
	$(foreach v,$(LIBOPENSSL1_COMPATIBILITY_VERSIONS),\
		ln -sf libcrypto.so.$(LIBOPENSSL1_SO_ENDING) $(TARGET_libdir)/libcrypto.so.$(v)$(sep))
	$(foreach v,$(LIBOPENSSL1_COMPATIBILITY_VERSIONS),\
		ln -sf libssl.so.$(LIBOPENSSL1_SO_ENDING) $(TARGET_libdir)/libssl.so.$(v)$(sep))
endef
LIBOPENSSL1_TARGET_FINALIZE_HOOKS += LIBOPENSSL1_COMPATIBILITY_LINKS

libopenssl1: | $(TARGET_DIR)
	$(call autotools-package)
