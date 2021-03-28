################################################################################
#
# readline
#
################################################################################

READLINE_VERSION = 8.1
READLINE_DIR = readline-$(READLINE_VERSION)
READLINE_SOURCE = readline-$(READLINE_VERSION).tar.gz
READLINE_SITE = $(GNU_MIRROR)/readline

READLINE_CONF_ENV = \
	bash_cv_func_sigsetjmp=yes \
	bash_cv_wcwidth_broken=no

READLINE_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-install-examples

readline: | $(TARGET_DIR)
	$(call autotools-package)
