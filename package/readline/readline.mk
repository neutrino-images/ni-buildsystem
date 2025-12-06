################################################################################
#
# readline
#
################################################################################

READLINE_VERSION = 8.3
READLINE_DIR = readline-$(READLINE_VERSION)
READLINE_SOURCE = readline-$(READLINE_VERSION).tar.gz
READLINE_SITE = $(GNU_MIRROR)/readline

READLINE_DEPENDENCIES = ncurses

READLINE_CONF_ENV = \
	bash_cv_func_sigsetjmp=yes \
	bash_cv_wcwidth_broken=no

READLINE_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-bracketed-paste-default \
	--disable-install-examples \
	--with-curses \
	--with-shared-termcap-library

define READLINE_INSTALL_INPUTRC
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inputrc $(TARGET_sysconfdir)/inputrc
endef
READLINE_TARGET_FINALIZE_HOOKS += READLINE_INSTALL_INPUTRC

readline: | $(TARGET_DIR)
	$(call autotools-package)
