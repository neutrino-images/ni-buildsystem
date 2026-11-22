################################################################################
#
# qtwebchannel
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QTWEBCHANNEL_VERSION = 6a20afaeba182ce6e3faee592e1e85a0d3ec0fc6
QTWEBCHANNEL_DIR = qtwebchannel-$(QTWEBCHANNEL_VERSION)
QTWEBCHANNEL_SOURCE = qtwebchannel-$(QTWEBCHANNEL_VERSION).tar.bz2
QTWEBCHANNEL_SITE = $(QT5_SITE)/qtwebchannel/-/archive/$(QTWEBCHANNEL_VERSION)

QTWEBCHANNEL_DEPENDENCIES = qtbase qtdeclarative

QTWEBCHANNEL_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QTWEBCHANNEL_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

QTWEBCHANNEL_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qtwebchannel: | $(TARGET_DIR)
	$(call generic-package)
