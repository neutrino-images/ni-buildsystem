################################################################################
#
# minidlna
#
################################################################################

MINIDLNA_VERSION = 1.3.0
MINIDLNA_DIR = minidlna-$(MINIDLNA_VERSION)
MINIDLNA_SOURCE = minidlna-$(MINIDLNA_VERSION).tar.gz
MINIDLNA_SITE = https://sourceforge.net/projects/minidlna/files/minidlna/$(MINIDLNA_VERSION)

MINIDLNA_DEPENDENCIES = zlib sqlite libexif libjpeg-turbo libid3tag libogg libvorbis flac ffmpeg

MINIDLNA_AUTORECONF = YES

MINIDLNA_CONF_OPTS = \
	--localedir=$(REMOVE_localedir) \
	--with-log-path=/tmp/minidlna \
	--disable-static

define MINIDLNA_INSTALL_MINIDLNAD_CONF
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/minidlna.conf $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^media_dir=.*|media_dir=A,/media/sda1/music\nmedia_dir=V,/media/sda1/movies\nmedia_dir=P,/media/sda1/pictures|' $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^#user=.*|user=root|' $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^#friendly_name=.*|friendly_name=$(BOXTYPE)-$(BOXMODEL):ReadyMedia|' $(TARGET_sysconfdir)/minidlna.conf
endef
MINIDLNA_PRE_FOLLOWUP_HOOKS += MINIDLNA_INSTALL_MINIDLNAD_CONF

define MINIDLNA_INSTALL_MINIDLNAD_INIT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minidlnad.init $(TARGET_sysconfdir)/init.d/minidlnad
	$(UPDATE-RC.D) minidlnad defaults 75 25
endef
MINIDLNA_TARGET_FINALIZE_HOOKS += MINIDLNA_INSTALL_MINIDLNAD_INIT

minidlna: | $(TARGET_DIR)
	$(call autotools-package)
