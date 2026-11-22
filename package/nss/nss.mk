################################################################################
#
# nss
#
################################################################################

NSS_VERSION = 3.97
NSS_DIR = nss-$(NSS_VERSION)
NSS_SOURCE = nss-$(NSS_VERSION).tar.gz
NSS_SITE = https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_$(subst .,_,$(NSS_VERSION))_RTM/src

NSS_DEPENDENCIES = nspr sqlite zlib

NSS_DISTDIR = $(PKG_BUILD_DIR)/dist

NSS_BUILD_VARS = \
	MOZILLA_CLIENT=1 \
	NSPR_INCLUDE_DIR=$(TARGET_includedir)/nspr \
	NSPR_LIB_DIR=$(TARGET_libdir) \
	NS_USE_GCC=1 \
	NSS_DISABLE_GTESTS=1 \
	NSS_USE_SYSTEM_SQLITE=1 \
	NATIVE_CC="gcc" \
	OS_ARCH="Linux" \
	OS_RELEASE="2.6" \
	OS_TEST="arm" \
	NSS_ENABLE_WERROR=0 \
	SOURCE_MD_DIR=$(NSS_DISTDIR) \
	DIST=$(NSS_DISTDIR) \
	CHECKLOC=

# no configure: the target flags go into the Linux part of coreconf
define NSS_CONFIGURE_CMDS
	echo 'OS_CFLAGS += $(TARGET_CFLAGS)' >> $(PKG_BUILD_DIR)/nss/coreconf/Linux.mk
	echo 'LDFLAGS += $(TARGET_LDFLAGS)' >> $(PKG_BUILD_DIR)/nss/coreconf/Linux.mk
endef

define NSS_BUILD_CMDS
	$(TARGET_CONFIGURE_ENVIRONMENT) $(MAKE) -j1 -C $(PKG_BUILD_DIR)/nss coreconf $(NSS_BUILD_VARS)
	$(TARGET_CONFIGURE_ENVIRONMENT) $(MAKE) -j1 -C $(PKG_BUILD_DIR)/nss lib/dbm all $(NSS_BUILD_VARS) \
		NATIVE_FLAGS="-O2 -DLINUX" NATIVE_LDFLAGS=""
endef

define NSS_INSTALL_CMDS
	$(INSTALL) -d $(TARGET_libdir) $(TARGET_includedir)/nss $(TARGET_libdir)/pkgconfig
	$(INSTALL) -m 755 -t $(TARGET_libdir) $(NSS_DISTDIR)/lib/*.so
	$(INSTALL) -m 644 -t $(TARGET_includedir)/nss $(NSS_DISTDIR)/public/nss/*
	$(INSTALL) -m 644 -t $(TARGET_libdir) $(NSS_DISTDIR)/lib/*.a
	sed 's/@VERSION@/$(NSS_VERSION)/g' $(PKG_FILES_DIR)/nss.pc.in > $(TARGET_libdir)/pkgconfig/nss.pc
endef

nss: | $(TARGET_DIR)
	$(call generic-package)
