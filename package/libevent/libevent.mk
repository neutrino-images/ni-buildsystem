################################################################################
#
# libevent
#
################################################################################

LIBEVENT_VERSION = 2.1.12-stable
LIBEVENT_DIR = libevent-$(LIBEVENT_VERSION)
LIBEVENT_SOURCE = libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_SITE = https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VERSION)

LIBEVENT_DEPENDENCIES = openssl

define LIBEVENT_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/event_rpcgen.py
endef
LIBEVENT_TARGET_FOLLOWUP_HOOKS += LIBEVENT_TARGET_CLEANUP

libevent: | $(TARGET_DIR)
	$(call autotools-package)
