################################################################################
#
# qtwebchannel
#
################################################################################

QTWEBCHANNEL_VERSION = $(QT5_VERSION)
QTWEBCHANNEL_DIR = qtwebchannel-everywhere-src-$(QTWEBCHANNEL_VERSION)
QTWEBCHANNEL_SOURCE = qtwebchannel-everywhere-opensource-src-$(QTWEBCHANNEL_VERSION).tar.xz
QTWEBCHANNEL_SITE = $(QT5_SITE)

QTWEBCHANNEL_DEPENDENCIES = qtbase qtdeclarative

QTWEBCHANNEL_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QTWEBCHANNEL_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

qtwebchannel: | $(TARGET_DIR)
	$(call generic-package)
