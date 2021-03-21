################################################################################
#
# minicom
#
################################################################################

MINICOM_VERSION = 2.7.1
MINICOM_DIR = minicom-$(MINICOM_VERSION)
MINICOM_SOURCE = minicom-$(MINICOM_VERSION).tar.gz
MINICOM_SITE = http://fossies.org/linux/misc

$(DL_DIR)/$(MINICOM_SOURCE):
	$(download) $(MINICOM_SITE)/$(MINICOM_SOURCE)

MINICOM_DEPENDENCIES = ncurses

MINICOM_CONF_OPTS = \
	--disable-nls

define MINICOM_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,ascii-xfr runscript xminicom)
endef
MINICOM_TARGET_FINALIZE_HOOKS += MINICOM_TARGET_CLEANUP

minicom: | $(TARGET_DIR)
	$(call autotools-package)
