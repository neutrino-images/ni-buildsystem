################################################################################
#
# tvheadend
#
################################################################################

TVHEADEND_VERSION = master
TVHEADEND_DIR = tvheadend.git
TVHEADEND_SOURCE = tvheadend.git
TVHEADEND_SITE = https://github.com/tvheadend
TVHEADEND_SITE_METHOD = git

TVHEADEND_DEPENDENCIES = \
	host-python3 \
	dtv-scan-tables \
	libiconv \
	openssl

TVHEADEND_CONF_OPTS = \
	--prefix=$(prefix) \
	--arch="$(TARGET_ARCH)" \
	--cpu="$(TARGET_CPU)" \
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
	--enable-linuxdvb \
	--enable-timeshift

TVHEADEND_DEPENDENCIES += host-pngquant
TVHEADEND_CONF_OPTS += --enable-pngquant

TVHEADEND_DEPENDENCIES += ffmpeg
TVHEADEND_CONF_OPTS += --enable-libav

TVHEADEND_DEPENDENCIES += libdvbcsa
TVHEADEND_CONF_OPTS += --enable-tvhcsa

TVHEADEND_DEPENDENCIES += zlib
TVHEADEND_CONF_OPTS += --enable-zlib

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

TVHEADEND_MAKE_ENV = LANGUAGES="de en_US en_GB"

# Remove source files. We use the bundled web interface version.
define TVHEADEND_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datarootdir)/tvheadend/src
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_TARGET_CLEANUP

define TVHEADEND_INSTALL_INIT_SYSV
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/tvheadend.default $(TARGET_sysconfdir)/default/tvheadend
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/tvheadend.init $(TARGET_sysconfdir)/init.d/tvheadend
endef

tvheadend: | $(TARGET_DIR)
	$(call generic-package)
