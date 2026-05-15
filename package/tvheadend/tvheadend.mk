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

define TVHEADEND_ADD_USER
	rm -f $(TARGET_sysconfdir)/passwd
	-make $(TARGET_sysconfdir)/passwd
	echo "tvheadend:*:101:101::/home/tvheadend:/bin/false" >> $(TARGET_sysconfdir)/passwd
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_ADD_USER

define TVHEADEND_ADD_GROUP
	rm -f $(TARGET_sysconfdir)/group
	-make $(TARGET_sysconfdir)/group
	echo "tvheadend:x:101:tvheadend" >> $(TARGET_sysconfdir)/group
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_ADD_GROUP

define TVHEADEND_ADD_HOME
	$(INSTALL) -d $(TARGET_DIR)/home/tvheadend
	#chown tvheadend:tvheadend $(TARGET_DIR)/home/tvheadend
	#chmod 0700 $(TARGET_DIR)/home/tvheadend
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_ADD_HOME

# Remove source files. We use the bundled web interface version.
define TVHEADEND_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datarootdir)/tvheadend/src
endef
TVHEADEND_TARGET_FINALIZE_HOOKS += TVHEADEND_TARGET_CLEANUP

tvheadend: | $(TARGET_DIR)
	$(call generic-package)
