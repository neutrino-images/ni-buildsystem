################################################################################
#
# alsa-lib
#
################################################################################

ALSA_LIB_VERSION = 1.2.9
ALSA_LIB_DIR = alsa-lib-$(ALSA_LIB_VERSION)
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VERSION).tar.bz2
ALSA_LIB_SITE = https://www.alsa-project.org/files/pub/lib

ALSA_LIB_AUTORECONF = YES

ALSA_LIB_CONF_OPTS = \
	--with-alsa-devdir=/dev/snd/ \
	--with-plugindir=$(libdir)/alsa \
	--without-debug \
	--with-debug=no \
	--with-versioned=no \
	--enable-symbolic-functions \
	--enable-silent-rules \
	--disable-aload \
	--disable-rawmidi \
	--disable-resmgr \
	--disable-old-symbols \
	--disable-alisp \
	--disable-ucm \
	--disable-hwdep \
	--disable-python \
	--disable-topology

define ALSA_LIB_TARGET_CLEANUP
	find $(TARGET_datadir)/alsa/cards/ -name '*.conf' ! -name 'aliases.conf' | xargs --no-run-if-empty $(TARGET_RM)
	find $(TARGET_datadir)/alsa/pcm/ -name '*.conf' ! -name 'default.conf' ! -name 'dmix.conf' ! -name 'dsnoop.conf' | xargs --no-run-if-empty $(TARGET_RM)
	$(TARGET_RM) $(TARGET_datadir)/aclocal
endef
ALSA_LIB_TARGET_FINALIZE_HOOKS += ALSA_LIB_TARGET_CLEANUP

alsa-lib: | $(TARGET_DIR)
	$(call autotools-package)
