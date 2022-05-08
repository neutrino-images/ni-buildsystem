################################################################################
#
# libfuse
#
################################################################################

LIBFUSE_VERSION = 2.9.9
LIBFUSE_DIR = fuse-$(LIBFUSE_VERSION)
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VERSION).tar.gz
LIBFUSE_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VERSION)

# We're patching configure.ac
LIBFUSE_AUTORECONF = YES

LIBFUSE_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-static \
	--disable-example \
	--disable-mtab \
	--with-gnu-ld \
	--enable-util \
	--enable-lib

define LIBFUSE_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_sysconfdir)/udev
	$(TARGET_RM) $(TARGET_sysconfdir)/init.d/fuse
endef
LIBFUSE_TARGET_FINALIZE_HOOKS += LIBFUSE_TARGET_CLEANUP

libfuse: | $(TARGET_DIR)
	$(call autotools-package)
