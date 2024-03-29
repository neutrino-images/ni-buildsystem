################################################################################
#
# oniguruma
#
################################################################################

ONIGURUMA_VERSION = 6.9.8
ONIGURUMA_DIR = onig-$(ONIGURUMA_VERSION)
ONIGURUMA_SOURCE = onig-$(ONIGURUMA_VERSION).tar.gz
ONIGURUMA_SITE = https://github.com/kkos/oniguruma/releases/download/v$(ONIGURUMA_VERSION)

ONIGURUMA_CONFIG_SCRIPTS = onig-config

oniguruma: | $(TARGET_DIR)
	$(call autotools-package)
