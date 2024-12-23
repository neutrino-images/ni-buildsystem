################################################################################
#
# oscam
#
################################################################################

OSCAM_VERSION = master
OSCAM_DIR = oscam.git
OSCAM_SOURCE = oscam.git
OSCAM_SITE = https://git.streamboard.tv/common
OSCAM_SITE_METHOD = git

OSCAM_KEEP_BUILD_DIR = YES

OSCAM_CONF_OPTS = \
	--enable readers \
	--enable \
	CS_ANTICASC \
	CS_CACHEEX \
	CW_CYCLE_CHECK \
	HAVE_DVBAPI \
	IRDETO_GUESSING \
	LCDSUPPORT \
	READ_SDT_CHARSETS \
	WEBIF \
	WEBIF_JQUERY \
	WEBIF_LIVELOG \
	WITH_DEBUG \
	WITH_LB \
	WITH_NEUTRINO \
	\
	WITH_EMU \
	WITH_SOFTCAM \
	\
	MODULE_CAMD35 \
	MODULE_CAMD35_TCP \
	MODULE_CCCAM \
	MODULE_CCCSHARE \
	MODULE_CONSTCW \
	MODULE_GBOX \
	MODULE_MONITOR \
	MODULE_NEWCAMD \
	MODULE_RADEGAST \
	MODULE_SCAM \
	\
	CARDREADER_INTERNAL \
	CARDREADER_PHOENIX \
	CARDREADER_SC8IN1 \
	CARDREADER_SMARGO

# enable ssl
OSCAM_DEPENDENCIES += openssl
OSCAM_CONF_OPTS += \
	--enable WITH_SSL

# enable streamrelay
OSCAM_DEPENDENCIES += libdvbcsa
OSCAM_CONF_OPTS += \
	--enable MODULE_STREAMRELAY

ifeq ($(TARGET_ARCH),arm)
# enable/disable arm-neon
OSCAM_CONF_OPTS += \
	$(if $(findstring neon,$(TARGET_ABI)),--enable,--disable) WITH_ARM_NEON
endif

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
	EXTRA_CC_OPTS="$(TARGET_OPTIMIZATION)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	TOOLCHAIN_INC_DIR=$(TARGET_includedir) \
	\
	CONF_DIR=/var/tuxbox/config \
	LIST_SMARGO_BIN=$($(PKG)_LIST_SMARGO_BIN) \
	OSCAM_BIN=$($(PKG)_OSCAM_BIN)

# enable libusb
OSCAM_DEPENDENCIES += libusb
OSCAM_MAKE_OPTS += \
	USE_LIBUSB=1

# static libdvbcsa
OSCAM_MAKE_OPTS += \
	$(if $(findstring libdvbcsa,$(OSCAM_DEPENDENCIES)),\
		LIBDVBCSA_LIB=$(TARGET_libdir)/libdvbcsa.a)

ifeq ($(BOXTYPE),coolstream)
OSCAM_DEPENDENCIES += coolstream-libs

# enable coolapi
ifeq ($(BOXMODEL),nevis)
OSCAM_MAKE_OPTS += \
	USE_COOLAPI=1
else
OSCAM_MAKE_OPTS += \
	USE_COOLAPI2=1
endif
endif

# apply oscam-emu patch with OSCAM_EMU=yes
ifeq ($(OSCAM_EMU),yes)
OSCAM_DEPENDENCIES += oscam-emu

define OSCAM_EMU_APPLY_PATCH
	$(CD) $(PKG_BUILD_DIR); \
		$(PATCH0) $(DL_DIR)/$(OSCAM_EMU_SOURCE)/$(OSCAM_EMU_PATCH_FILE)
endef
OSCAM_PRE_PATCH_HOOKS += OSCAM_EMU_APPLY_PATCH
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
	$(call generic-package,$(PKG_NO_INSTALL))
