################################################################################
#
# libopenssl
#
################################################################################

LIBOPENSSL_VERSION = 1.1.1w
LIBOPENSSL_DIR = openssl-$(LIBOPENSSL_VERSION)
LIBOPENSSL_SOURCE = openssl-$(LIBOPENSSL_VERSION).tar.gz
LIBOPENSSL_SITE = $(GITHUB)/openssl/openssl/releases/download/OpenSSL_$(subst .,_,$(LIBOPENSSL_VERSION))

ifeq ($(TARGET_ARCH),arm)
  LIBOPENSSL_TARGET_ARCH = linux-armv4
else ifeq ($(TARGET_ARCH),mips)
  LIBOPENSSL_TARGET_ARCH = linux-generic32
endif

LIBOPENSSL_CONF_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

LIBOPENSSL_CONF_OPTS += \
	$(LIBOPENSSL_TARGET_ARCH) \
	shared \
	threads \
	no-hw \
	no-engine \
	no-sse2 \
	no-tests \
	no-fuzz-afl \
	no-fuzz-libfuzzer

LIBOPENSSL_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DLIBOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

define LIBOPENSSL_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		./Configure $($(PKG)_CONF_OPTS)
endef

define LIBOPENSSL_PATCH_MAKEFILE
	$(SED) 's| build_tests||' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' $(PKG_BUILD_DIR)/Makefile
	$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' $(PKG_BUILD_DIR)/Makefile
endef
LIBOPENSSL_POST_CONFIGURE_HOOKS += LIBOPENSSL_PATCH_MAKEFILE

define LIBOPENSSL_MAKE_DEPEND
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_MAKE) depend
endef
LIBOPENSSL_PRE_BUILD_HOOKS += LIBOPENSSL_MAKE_DEPEND

LIBOPENSSL_MAKE_INSTALL_ARGS = \
	install_sw \
	install_ssldirs

define LIBOPENSSL_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/c_rehash
	$(TARGET_RM) $(TARGET_libdir)/engines-1.1
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/ct_log_list.cnf*
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.pl,tsget*}
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/openssl.cnf.dist
endef
LIBOPENSSL_TARGET_FINALIZE_HOOKS += LIBOPENSSL_TARGET_CLEANUP

LIBOPENSSL_SO_ENDING = 1.1
LIBOPENSSL_COMPATIBILITY_VERSIONS = 0.9.7 0.9.8 1.0.0 1.0.2 1.1.0

define LIBOPENSSL_COMPATIBILITY_LINKS
	$(foreach v,$(LIBOPENSSL_COMPATIBILITY_VERSIONS),\
		ln -sf libcrypto.so.$(LIBOPENSSL_SO_ENDING) $(TARGET_libdir)/libcrypto.so.$(v)$(sep))
	$(foreach v,$(LIBOPENSSL_COMPATIBILITY_VERSIONS),\
		ln -sf libssl.so.$(LIBOPENSSL_SO_ENDING) $(TARGET_libdir)/libssl.so.$(v)$(sep))
endef
LIBOPENSSL_TARGET_FINALIZE_HOOKS += LIBOPENSSL_COMPATIBILITY_LINKS

libopenssl: | $(TARGET_DIR)
	$(call autotools-package)
