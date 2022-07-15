################################################################################
#
# sqlite
#
################################################################################

SQLITE_VERSION = 3390000
SQLITE_DIR = sqlite-autoconf-$(SQLITE_VERSION)
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VERSION).tar.gz
SQLITE_SITE = http://www.sqlite.org/2022

SQLITE_CONF_OPTS = \
	--bindir=$(REMOVE_bindir)

sqlite: | $(TARGET_DIR)
	$(call autotools-package)
