################################################################################
#
# qt5 - common settings of the Qt 5 modules
#
################################################################################

QT5_VERSION_MAJOR = 5.15
QT5_VERSION = $(QT5_VERSION_MAJOR).16
QT5_SITE = https://download.qt.io/archive/qt/$(QT5_VERSION_MAJOR)/$(QT5_VERSION)/submodules

# qmake of the cross build of qtbase, a host tool
QT5_QMAKE = $(HOST_DIR)/bin/qmake

# a Qt module or application built with that qmake; make install puts it
# into the target tree, the sysroot qtbase was configured with
define QT5_QMAKE_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(QT5_QMAKE) $($(PKG)_QMAKE_OPTS)
endef

define QT5_QMAKE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) install
endef
