################################################################################
#
# qtdeclarative
#
################################################################################

QTDECLARATIVE_VERSION = $(QT5_VERSION)
QTDECLARATIVE_DIR = qtdeclarative-everywhere-src-$(QTDECLARATIVE_VERSION)
QTDECLARATIVE_SOURCE = qtdeclarative-everywhere-opensource-src-$(QTDECLARATIVE_VERSION).tar.xz
QTDECLARATIVE_SITE = $(QT5_SITE)

QTDECLARATIVE_DEPENDENCIES = qtbase

QTDECLARATIVE_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QTDECLARATIVE_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

qtdeclarative: | $(TARGET_DIR)
	$(call generic-package)
