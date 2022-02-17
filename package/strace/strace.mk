################################################################################
#
# strace
#
################################################################################

STRACE_VERSION = 5.1
STRACE_DIR = strace-$(STRACE_VERSION)
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.xz
STRACE_SITE = https://strace.io/files/$(STRACE_VERSION)

$(DL_DIR)/$(STRACE_SOURCE):
	$(download) $(STRACE_SITE)/$(STRACE_SOURCE)

strace: $(DL_DIR)/$(STRACE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(STRACE_DIR)
	$(UNTAR)/$(STRACE_SOURCE)
	$(CHDIR)/$(STRACE_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,strace-graph strace-log-merge)
	$(REMOVE)/$(STRACE_DIR)
	$(TOUCH)
