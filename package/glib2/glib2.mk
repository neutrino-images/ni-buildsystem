################################################################################
#
# glib2
#
################################################################################

GLIB2_VERSION_MAJOR = 2.88
GLIB2_VERSION = $(GLIB2_VERSION_MAJOR).4
GLIB2_DIR = glib-$(GLIB2_VERSION)
GLIB2_SOURCE = glib-$(GLIB2_VERSION).tar.xz
GLIB2_SITE = https://download.gnome.org/sources/glib/$(GLIB2_VERSION_MAJOR)

GLIB2_DEPENDENCIES = zlib libffi pcre2

# uClibc-ng has no libintl; glib2 needs one
ifeq ($(BOXSERIES),hd2)
  GLIB2_DEPENDENCIES += gettext
endif

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  GLIB2_DEPENDENCIES += libiconv
endif

# We explicitly specify a giomodule-dir to avoid having a value
# containing ${libdir} in gio-2.0.pc. Indeed, a value depending on
# ${libdir} would be prefixed by the sysroot by pkg-config, causing a
# bogus installation path once combined with $(DESTDIR).
GLIB2_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datadir=$(REMOVE_datadir) \
	$(if $(filter $(BOXSERIES),hd1),-Ddefault_library=static) \
	-Dgio_module_dir=$(libdir)/gio/modules \
	-Dglib_debug=disabled \
	-Dlibelf=disabled \
	-Dlibmount=disabled \
	-Dselinux=disabled \
	-Dxattr=false \
	-Dintrospection=disabled \
	-Dsysprof=disabled \
	-Ddtrace=disabled \
	-Dsystemtap=disabled \
	-Dman-pages=disabled \
	-Ddocumentation=false \
	-Dnls=disabled \
	-Dtests=false \
	-Dinstalled_tests=false \
	-Doss_fuzz=disabled

# glib2 can't run target binaries while cross-compiling; tell it what the
# toolchains provide
GLIB2_MESON_EXTRA_PROPERTIES = \
	have_c99_vsnprintf=true \
	have_c99_snprintf=true \
	have_unix98_printf=true

# glib-genmarshal, glib-mkenums and friends are referenced with a ${bindir}/
# prefix in the pkg-config files. Remove the prefix so that the programs are
# looked up in PATH and not in TARGET_DIR.
define GLIB2_REMOVE_BINDIR_PREFIX_FROM_PC_FILE
	$(SED) 's%$${bindir}/%%g' $(addprefix $(TARGET_libdir)/pkgconfig/,glib-2.0.pc gio-2.0.pc)
endef
GLIB2_TARGET_FINALIZE_HOOKS += GLIB2_REMOVE_BINDIR_PREFIX_FROM_PC_FILE

define GLIB2_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libexecdir)/gio-launch-desktop
endef
GLIB2_TARGET_FINALIZE_HOOKS += GLIB2_TARGET_CLEANUP

glib2: | $(TARGET_DIR)
	$(call meson-package)
