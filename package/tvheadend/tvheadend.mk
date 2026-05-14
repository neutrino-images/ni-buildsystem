################################################################################
#
# tvheadend
#
################################################################################

TVHEADEND_VERSION = 37453bc3fe5f9e10f3428ebb1abdc613f8b07186
TVHEADEND_DIR = tvheadend-$(TVHEADEND_VERSION)
TVHEADEND_SOURCE = tvheadend-$(TVHEADEND_VERSION).tar.gz
TVHEADEND_SITE = $(call github,tvheadend,tvheadend,$(TVHEADEND_VERSION))

TVHEADEND_DEPENDENCIES = \
	host-python3 \
	dtv-scan-tables \
	libiconv \
	openssl

# FIXME: cortex-a15 is hardcoded; needs buildsystem reworks
TVHEADEND_CONF_OPTS = \
	--prefix=$(prefix) \
	--arch="$(TARGET_ARCH)" \
	--cpu="cortex-a15" \
	--nowerror \
	--python="$(HOST_PYTHON_BINARY)" \
	--disable-dbus-1 \
	--disable-execinfo \
	--disable-ffmpeg_static \
	--disable-hdhomerun_client \
	--disable-hdhomerun_static \
	--disable-libopus \
	--disable-libvpx \
	--disable-libx264 \
	--disable-libx265 \
	--disable-omx \
	--disable-pcre \
	--disable-pcre2 \
	--disable-pie \
	--disable-vaapi \
	--enable-bundle \
	--enable-capmt \
	--enable-cardclient \
	--enable-cccam \
	--enable-constcw \
	--enable-cwc \
	--enable-dvbscan \
	--enable-iptv \
	--enable-satip_client \
	--enable-satip_server \
	--enable-timeshift

TVHEADEND_DEPENDENCIES += host-pngquant
TVHEADEND_CONF_OPTS += --enable-pngquant

TVHEADEND_DEPENDENCIES += ffmpeg
TVHEADEND_CONF_OPTS += --enable-libav

TVHEADEND_DEPENDENCIES += libdvbcsa
TVHEADEND_CONF_OPTS += --enable-tvhcsa

# The tvheadend build system expects the transponder data to be present inside
# its source tree. To prevent a download initiated by the build system just
# copy the data files in the right place and add the corresponding stamp file.
define TVHEADEND_INSTALL_DTV_SCAN_TABLES
	$(INSTALL) -d $(PKG_BUILD_DIR)/data/dvb-scan
	$(INSTALL_COPY) $(TARGET_datarootdir)/dvb/* $(PKG_BUILD_DIR)/data/dvb-scan/
	touch $(PKG_BUILD_DIR)/data/dvb-scan/.stamp
endef
TVHEADEND_PRE_CONFIGURE_HOOKS += TVHEADEND_INSTALL_DTV_SCAN_TABLES

define TVHEADEND_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
			$(TARGET_CONFIGURE_OPTS) $($(PKG)_CONF_OPTS)
endef

define TVHEADEND_FIX_PNGQUANT_PATH
	$(SED) "s%^pngquant_bin =.*%pngquant_bin = '$(HOST_PNGQUANT_BINARY)'%" \
		$(PKG_BUILD_DIR)/support/mkbundle
endef
TVHEADEND_POST_CONFIGURE_HOOKS += TVHEADEND_FIX_PNGQUANT_PATH

# Remove documentation and source files that are not needed because we
# use the bundled web interface version.
define TVHEADEND_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datarootdir)/tvheadend/{docs,src}
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_TARGET_CLEANUP

tvheadend: | $(TARGET_DIR)
	$(call generic-package)
