################################################################################
#
# xfsprogs
#
################################################################################

XFSPROGS_VERSION = 5.9.0
XFSPROGS_DIR = xfsprogs-$(XFSPROGS_VERSION)
XFSPROGS_SOURCE = xfsprogs-$(XFSPROGS_VERSION).tar.xz
XFSPROGS_SITE = $(KERNEL_MIRROR)/linux/utils/fs/xfs/xfsprogs

XFSPROGS_DEPENDENCIES = util-linux

XFSPROGS_CONF_ENV = \
	ac_cv_header_aio_h=yes \
	ac_cv_lib_rt_lio_listio=yes \
	PLATFORM="linux"

XFSPROGS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-lib64=no \
	--enable-gettext=no \
	--disable-libicu \
	INSTALL_USER=root \
	INSTALL_GROUP=root \
	--enable-static

define XFSPROGS_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,xfsprogs)
endef
XFSPROGS_TARGET_FINALIZE_HOOKS += XFSPROGS_TARGET_CLEANUP

xfsprogs: | $(TARGET_DIR)
	$(call autotools-package)
