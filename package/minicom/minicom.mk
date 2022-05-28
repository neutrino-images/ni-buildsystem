################################################################################
#
# minicom
#
################################################################################

MINICOM_VERSION = 2.8
MINICOM_DIR = minicom-$(MINICOM_VERSION)
MINICOM_SOURCE = minicom-$(MINICOM_VERSION).tar.gz
MINICOM_SITE = https://salsa.debian.org/minicom-team/minicom/-/archive/$(MINICOM_VERSION)

MINICOM_DEPENDENCIES = ncurses

MINICOM_CONF_OPTS = \
	--disable-nls

define MINICOM_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,ascii-xfr runscript xminicom)
endef
MINICOM_TARGET_FINALIZE_HOOKS += MINICOM_TARGET_CLEANUP

minicom: | $(TARGET_DIR)
	$(call autotools-package)
