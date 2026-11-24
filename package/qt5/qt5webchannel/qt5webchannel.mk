################################################################################
#
# qt5webchannel
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QT5WEBCHANNEL_VERSION = 6a20afaeba182ce6e3faee592e1e85a0d3ec0fc6
QT5WEBCHANNEL_DIR = qtwebchannel-$(QT5WEBCHANNEL_VERSION)
QT5WEBCHANNEL_SOURCE = qtwebchannel-$(QT5WEBCHANNEL_VERSION).tar.bz2
QT5WEBCHANNEL_SITE = $(QT5_SITE)/qtwebchannel/-/archive/$(QT5WEBCHANNEL_VERSION)

QT5WEBCHANNEL_DEPENDENCIES = qt5base qt5declarative

QT5WEBCHANNEL_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QT5WEBCHANNEL_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

QT5WEBCHANNEL_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qt5webchannel: | $(TARGET_DIR)
	$(call generic-package)
