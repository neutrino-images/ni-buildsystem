################################################################################
#
# xz
#
################################################################################

XZ_VERSION = 5.4.2
XZ_DIR = xz-$(XZ_VERSION)
XZ_SOURCE = xz-$(XZ_VERSION).tar.xz
XZ_SITE = https://tukaani.org/xz

XZ_CONF_ENV = \
	ac_cv_prog_cc_c99='-std=gnu99'

XZ_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-small \
	--enable-assume-ram=4 \
	--disable-assembler \
	--disable-debug \
	--disable-doc \
	--disable-rpath \
	--disable-symbol-versions \
	--disable-werror \
	--with-pic

xz: | $(TARGET_DIR)
	$(call autotools-package)
