################################################################################
#
# qtdeclarative
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QTDECLARATIVE_VERSION = 5bc1ac07b2d2c7839368084a4bb97e4c67eb8294
QTDECLARATIVE_DIR = qtdeclarative-$(QTDECLARATIVE_VERSION)
QTDECLARATIVE_SOURCE = qtdeclarative-$(QTDECLARATIVE_VERSION).tar.bz2
QTDECLARATIVE_SITE = $(QT5_SITE)/qtdeclarative/-/archive/$(QTDECLARATIVE_VERSION)

QTDECLARATIVE_DEPENDENCIES = qtbase

QTDECLARATIVE_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)
QTDECLARATIVE_INSTALL_CMDS = $(QT5_QMAKE_INSTALL_CMDS)

QTDECLARATIVE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qtdeclarative: | $(TARGET_DIR)
	$(call generic-package)
