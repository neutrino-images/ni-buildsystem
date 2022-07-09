################################################################################
#
# dvb-apps
#
################################################################################

DVB_APPS_VERSION = hg
DVB_APPS_DIR = dvb-apps
DVB_APPS_SOURCE = dvb-apps
DVB_APPS_SITE = https://linuxtv.org/hg

DVB_APPS_CHECKOUT = 3d43b280298c39a67d1d889e01e173f52c12da35

DVB_APPS_DEPENDENCIES = kernel-headers libiconv

DVB_APPS_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	LDLIBS="-liconv"

DVB_APPS_MAKE_OPTS = \
	enable_shared=no \
	KERNEL_HEADERS=$(KERNEL_HEADERS_DIR) \
	PERL5LIB=$(PKG_BUILD_DIR)/util/scan \

dvb-apps: | $(TARGET_DIR)
	$(call generic-package)
