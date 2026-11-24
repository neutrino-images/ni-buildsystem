################################################################################
#
# qt5declarative
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QT5DECLARATIVE_VERSION = 5bc1ac07b2d2c7839368084a4bb97e4c67eb8294
QT5DECLARATIVE_DIR = qtdeclarative-$(QT5DECLARATIVE_VERSION)
QT5DECLARATIVE_SOURCE = qtdeclarative-$(QT5DECLARATIVE_VERSION).tar.bz2
QT5DECLARATIVE_SITE = $(QT5_SITE)/qtdeclarative/-/archive/$(QT5DECLARATIVE_VERSION)

QT5DECLARATIVE_DEPENDENCIES = qt5base

QT5DECLARATIVE_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QT5DECLARATIVE_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

QT5DECLARATIVE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qt5declarative: | $(TARGET_DIR)
	$(call generic-package)
