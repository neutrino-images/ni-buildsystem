################################################################################
#
# openssl
#
################################################################################

OPENSSL_VERSION = 1.0.2u
OPENSSL_DIR = openssl-$(OPENSSL_VERSION)
OPENSSL_SOURCE = openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE = https://www.openssl.org/source

$(DL_DIR)/$(OPENSSL_SOURCE):
	$(download) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

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
	no-perlasm \
	no-tests \
	no-fuzz-afl \
	no-fuzz-libfuzzer

OPENSSL_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

openssl: $(DL_DIR)/$(OPENSSL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		./Configure \
			$($(PKG)_CONF_OPTS); \
		$(SED) 's| build_tests||' Makefile; \
		$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' Makefile; \
		$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' Makefile; \
		$(MAKE) depend; \
		$(MAKE); \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGET_DIR)
	$(TARGET_RM) $(TARGET_libdir)/engines
	$(TARGET_RM) $(TARGET_bindir)/c_rehash
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.pl,tsget}
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(TARGET_RM) $(TARGET_bindir)/openssl
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*}
endif
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
	for version in 0.9.7 0.9.8 1.0.2; do \
		ln -sf libcrypto.so.1.0.0 $(TARGET_libdir)/libcrypto.so.$$version; \
		ln -sf libssl.so.1.0.0 $(TARGET_libdir)/libssl.so.$$version; \
	done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
