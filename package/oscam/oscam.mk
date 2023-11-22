################################################################################
#
# oscam
#
################################################################################

OSCAM_VERSION = HEAD
OSCAM_DIR = oscam.svn
OSCAM_SOURCE = oscam.svn
OSCAM_SITE = https://svn.streamboard.tv/oscam/trunk
OSCAM_SITE_METHOD = svn

OSCAM_DEPENDENCIES = $(if $(filter $(BOXTYPE),coolstream),blobs)

OSCAM_KEEP_BUILD_DIR = YES

OSCAM_CONF_OPTS = \
	--enable \
	CLOCKFIX \
	CS_ANTICASC \
	CS_CACHEEX \
	CW_CYCLE_CHECK \
	HAVE_DVBAPI \
	IRDETO_GUESSING \
	MODULE_MONITOR \
	READ_SDT_CHARSETS \
	TOUCH \
	LCDSUPPORT \
	WEBIF \
	WEBIF_JQUERY \
	WEBIF_LIVELOG \
	WITH_DEBUG \
	WITH_LB \
	WITH_NEUTRINO \
	\
	MODULE_CAMD35 \
	MODULE_CAMD35_TCP \
	MODULE_CCCAM \
	MODULE_CCCSHARE \
	MODULE_CONSTCW \
	MODULE_GBOX \
	MODULE_NEWCAMD \
	\
	READER_CONAX \
	READER_CRYPTOWORKS \
	READER_IRDETO \
	READER_NAGRA \
	READER_NAGRA_MERLIN \
	READER_SECA \
	READER_VIACCESS \
	READER_VIDEOGUARD \
	\
	CARDREADER_INTERNAL \
	CARDREADER_PHOENIX \
	CARDREADER_SC8IN1 \
	CARDREADER_SMARGO

define OSCAM_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		./config.sh $($(PKG)_CONF_OPTS)
endef

OSCAM_LIST_SMARGO_BIN =# $(TARGET_localstatedir)/bin/oscam_list_smargo
OSCAM_OSCAM_BIN = $(TARGET_localstatedir)/bin/oscam

OSCAM_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

OSCAM_MAKE_OPTS = \
	CROSS=$(TARGET_CROSS) \
	CC_OPTS="-pipe -O2" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	\
	PLUS_TARGET="-rezap" \
	CONF_DIR="/var/tuxbox/config" \
	LIST_SMARGO_BIN=$($(PKG)_LIST_SMARGO_BIN) \
	OSCAM_BIN=$($(PKG)_OSCAM_BIN)

# enable ssl
OSCAM_DEPENDENCIES += openssl
OSCAM_CONF_OPTS += \
	WITH_SSL

# enable libusb
OSCAM_DEPENDENCIES += libusb
OSCAM_MAKE_OPTS += \
	USE_LIBUSB=1 \

# enable emu with OSCAM_EMU=yes
ifeq ($(OSCAM_EMU),yes)
OSCAM_DEPENDENCIES += oscam-emu
OSCAM_CONF_OPTS += \
	WITH_EMU \
	WITH_SOFTCAM

define OSCAM_EMU_APPLY_PATCH
	$(CD) $(PKG_BUILD_DIR); \
		$(PATCH0) $(DL_DIR)/$(OSCAM_EMU_SOURCE)/$(OSCAM_EMU_PATCH_FILE)
endef
OSCAM_PRE_PATCH_HOOKS += OSCAM_EMU_APPLY_PATCH
endif

# enable coolapi
ifeq ($(BOXTYPE),coolstream)
ifeq ($(BOXMODEL),nevis)
OSCAM_MAKE_OPTS += \
	USE_COOLAPI=1
else
OSCAM_MAKE_OPTS += \
	USE_COOLAPI2=1
endif
endif

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),kronos kronos_v2))
define OSCAM_FIXUP_MAX_COOL_DMX
	$(SED) "s|^#define MAX_COOL_DMX.*|#define MAX_COOL_DMX 3|" $(PKG_BUILD_DIR)/module-dvbapi-coolapi.c
	$(SED) "s|^#define MAX_COOL_DMX.*|#define MAX_COOL_DMX 3|" $(PKG_BUILD_DIR)/module-dvbapi-coolapi-legacy.c
endef
OSCAM_POST_PATCH_HOOKS += OSCAM_FIXUP_MAX_COOL_DMX
endif

define OSCAM_TARGET_CLEANUP
	$(TARGET_RM) $($(PKG)_OSCAM_BIN).debug
endef
OSCAM_TARGET_FINALIZE_HOOKS += OSCAM_TARGET_CLEANUP

oscam: | $(TARGET_DIR)
	$(call autotools-package,$(PKG_NO_INSTALL))
