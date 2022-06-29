################################################################################
#
# rtmpdump
#
################################################################################

RTMPDUMP_VERSION = ni-git
RTMPDUMP_DIR = $(NI_RTMPDUMP)
RTMPDUMP_SOURCE = $(NI_RTMPDUMP)
RTMPDUMP_SITE = https://github.com/neutrino-images

RTMPDUMP_DEPENDENCIES = zlib openssl

RTMPDUMP_MAKE_ENV = \
	CROSS_COMPILE=$(TARGET_CROSS) \
	XCFLAGS="$(TARGET_CFLAGS)" \
	XLDFLAGS="$(TARGET_LDFLAGS)"

RTMPDUMP_MAKE_OPTS = \
	prefix=$(prefix) \
	mandir=$(REMOVE_mandir)

define RTMPDUMP_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,rtmpgw rtmpsrv rtmpsuck)
endef
RTMPDUMP_TARGET_FINALIZE_HOOKS += RTMPDUMP_TARGET_CLEANUP

rtmpdump: | $(TARGET_DIR)
	$(call generic-package)
