################################################################################
#
# giflib
#
################################################################################

GIFLIB_VERSION = 6.1.3
GIFLIB_DIR = giflib-$(GIFLIB_VERSION)
GIFLIB_SOURCE = giflib-$(GIFLIB_VERSION).tar.gz
GIFLIB_SITE = https://sourceforge.net/projects/giflib/files

GIFLIB_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

GIFLIB_MAKE_INSTALL_OPTS = \
	PREFIX=$(prefix) \
	BINDIR=$(REMOVE_bindir) \
	MANDIR=$(REMOVE_mandir) \
	DOCDIR=$(REMOVE_docdir)/giflib

giflib: | $(TARGET_DIR)
	$(call generic-package)
