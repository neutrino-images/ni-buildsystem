################################################################################
#
# rtmpdump
#
################################################################################

RTMPDUMP_DEPENDENCIES = zlib openssl

RTMPDUMP_MAKE_ENV = \
	CROSS_COMPILE=$(TARGET_CROSS) \
	XCFLAGS="$(TARGET_CFLAGS)" \
	XLDFLAGS="$(TARGET_LDFLAGS)"

RTMPDUMP_MAKE_OPTS = \
	prefix=$(prefix) \
	mandir=$(REMOVE_mandir)

rtmpdump: $(RTMPDUMP_DEPENDENCIES) $(SOURCE_DIR)/$(NI_RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI_RTMPDUMP)
	tar -C $(SOURCE_DIR) --exclude-vcs -cp $(NI_RTMPDUMP) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_RTMPDUMP); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,rtmpgw rtmpsrv rtmpsuck)
	$(REMOVE)/$(NI_RTMPDUMP)
	$(TOUCH)
