################################################################################
#
# strace
#
################################################################################

STRACE_VERSION = 6.2
STRACE_DIR = strace-$(STRACE_VERSION)
STRACE_SOURCE = strace-$(STRACE_VERSION).tar.xz
STRACE_SITE = https://strace.io/files/$(STRACE_VERSION)

define STRACE_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,strace-graph strace-log-merge)
endef
STRACE_TARGET_FINALIZE_HOOKS += STRACE_TARGET_CLEANUP

strace: | $(TARGET_DIR)
	$(call autotools-package)
