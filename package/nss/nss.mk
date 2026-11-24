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

# -----------------------------------------------------------------------------

HOST_NSS_DEPENDENCIES = host-nspr host-sqlite host-zlib

HOST_NSS_BUILD_VARS = \
	MOZILLA_CLIENT=1 \
	NSPR_INCLUDE_DIR=$(HOST_DIR)/include/nspr \
	NSPR_LIB_DIR=$(HOST_DIR)/lib \
	NS_USE_GCC=1 \
	NSS_DISABLE_GTESTS=1 \
	NSS_USE_SYSTEM_SQLITE=1 \
	SQLITE_INCLUDE_DIR=$(HOST_DIR)/include \
	SQLITE_LIB_DIR=$(HOST_DIR)/lib \
	ZLIB_INCLUDE_DIR=$(HOST_DIR)/include \
	NSS_ENABLE_WERROR=0 \
	FREEBL_NO_DEPEND=1 \
	RPATH=-Wl,-rpath,$(HOST_DIR)/lib \
	SOURCE_MD_DIR=$(NSS_DISTDIR) \
	DIST=$(NSS_DISTDIR) \
	CHECKLOC=

ifeq ($(shell getconf LONG_BIT),64)
HOST_NSS_BUILD_VARS += USE_64=1
endif

# no configure, and nss ignores CFLAGS from the environment: host/include
# (sqlite3.h, ...) goes into the Linux part of coreconf, as for the target
define HOST_NSS_CONFIGURE_CMDS
	echo 'OS_CFLAGS += $(HOST_CPPFLAGS)' >> $(PKG_BUILD_DIR)/nss/coreconf/Linux.mk
endef

# -j1: the sub-makes print jobserver warnings into $(SUB_SHLOBJS)
define HOST_NSS_BUILD_CMDS
	$(HOST_CONFIGURE_ENV) $(MAKE) -j1 -C $(PKG_BUILD_DIR)/nss coreconf $(HOST_NSS_BUILD_VARS)
	$(HOST_CONFIGURE_ENV) $(MAKE) -j1 -C $(PKG_BUILD_DIR)/nss lib/dbm all $(HOST_NSS_BUILD_VARS)
endef

define HOST_NSS_INSTALL_CMDS
	$(INSTALL) -d $(HOST_DIR)/lib/pkgconfig $(HOST_DIR)/include/nss
	$(INSTALL) -m 755 -t $(HOST_DIR)/lib $(NSS_DISTDIR)/lib/*.so
	$(INSTALL) -m 644 -t $(HOST_DIR)/include/nss $(NSS_DISTDIR)/public/nss/*
	$(INSTALL) -m 644 -t $(HOST_DIR)/lib $(NSS_DISTDIR)/lib/*.a
	sed -e 's|@VERSION@|$(NSS_VERSION)|g' \
		-e 's|^prefix=.*|prefix=$(HOST_DIR)|' \
		-e 's|^Libs: -L$${libdir}|Libs: -L$${libdir} -Wl,-rpath,$${libdir}|' \
		$(PKG_FILES_DIR)/nss.pc.in > $(HOST_DIR)/lib/pkgconfig/nss.pc
endef

host-nss: | $(HOST_DIR)
	$(call host-generic-package)
