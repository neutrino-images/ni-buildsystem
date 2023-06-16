################################################################################
#
# glib2
#
################################################################################

GLIB2_VERSION = 2.56.3
GLIB2_DIR = glib-$(GLIB2_VERSION)
GLIB2_SOURCE = glib-$(GLIB2_VERSION).tar.xz
GLIB2_SITE = https://ftp.gnome.org/pub/gnome/sources/glib/$(basename $(GLIB2_VERSION))

GLIB2_DEPENDENCIES = zlib libffi
ifeq ($(BOXSERIES),hd2)
  GLIB2_DEPENDENCIES += gettext
endif

GLIB2_AUTORECONF = YES

GLIB2_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datadir=$(REMOVE_datadir) \
	$(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared) \
	--cache-file=arm-linux.cache \
	--disable-debug \
	--disable-selinux \
	--disable-libmount \
	--disable-fam \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-compile-warnings \
	--with-threads="posix" \
	--with-pcre=internal

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  GLIB2_DEPENDENCIES += libiconv
  GLIB2_CONF_OPTS += --with-libiconv=gnu
endif

define GLIB2_CREATE_CONF_ENV_FILE
	echo "ac_cv_func_posix_getgrgid_r=yes"	 > $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "ac_cv_func_posix_getpwuid_r=yes"	>> $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "ac_cv_type_long_long=yes"		>> $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "glib_cv_stack_grows=no"		>> $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "glib_cv_uscore=no"		>> $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "glib_cv_va_copy=no"		>> $($(PKG)_BUILD_DIR)/arm-linux.cache
	echo "glib_cv_va_val_copy=yes"		>> $($(PKG)_BUILD_DIR)/arm-linux.cache
endef
GLIB2_POST_PATCH_HOOKS += GLIB2_CREATE_CONF_ENV_FILE

glib2: | $(TARGET_DIR)
	$(call autotools-package)
