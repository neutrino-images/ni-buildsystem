################################################################################
#
# luajit
#
################################################################################

LUAJIT_VERSION = 871db2c84ecefd70a850e03a6c340214a81739f0
LUAJIT_DIR = luajit.git
LUAJIT_SOURCE = luajit.git
LUAJIT_SITE = $(GITHUB)/luajit
LUAJIT_SITE_METHOD = git

LUAJIT_XCFLAGS = \
	-DLUAJIT_ENABLE_LUA52COMPAT \
	-DLUAJIT_DISABLE_GC64

LUAJIT_HOST_CC = \
	$(HOSTCC) -m32

# We unfortunately can't use TARGET_CONFIGURE_OPTS, because the luajit
# build system uses non conventional variable names.
define LUAJIT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
		PREFIX="$(prefix)" \
		STATIC_CC="$(TARGET_CC)" \
		DYNAMIC_CC="$(TARGET_CC) -fPIC" \
		TARGET_LD="$(TARGET_CC)" \
		TARGET_AR="$(TARGET_AR) rcus" \
		TARGET_STRIP=true \
		TARGET_CFLAGS="$(TARGET_CFLAGS)" \
		TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
		HOST_CC="$(LUAJIT_HOST_CC)" \
		HOST_CFLAGS="$(HOST_CFLAGS)" \
		HOST_LDFLAGS="$(HOST_LDFLAGS)" \
		BUILDMODE=dynamic \
		XCFLAGS="$(LUAJIT_XCFLAGS)" \
		-C $(PKG_BUILD_DIR) amalg
endef

define LUAJIT_INSTALL_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) \
		PREFIX="$(prefix)" \
		DESTDIR="$(TARGET_DIR)" \
		LDCONFIG=true \
		-C $(PKG_BUILD_DIR) install
endef

define LUAJIT_INSTALL_SYMLINK
	ln -fs luajit $(TARGET_bindir)/lua
endef
LUAJIT_TARGET_FINALIZE_HOOKS += LUAJIT_INSTALL_SYMLINK

define LUAJIT_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_mandir)
endef
LUAJIT_TARGET_FINALIZE_HOOKS += LUAJIT_TARGET_CLEANUP

luajit: | $(TARGET_DIR)
	$(call generic-package)
