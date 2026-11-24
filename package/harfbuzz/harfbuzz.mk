################################################################################
#
# harfbuzz
#
################################################################################

HARFBUZZ_VERSION = 8.4.0
HARFBUZZ_DIR = harfbuzz-$(HARFBUZZ_VERSION)
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VERSION).tar.xz
HARFBUZZ_SITE = https://github.com/harfbuzz/harfbuzz/releases/download/$(HARFBUZZ_VERSION)

HARFBUZZ_DEPENDENCIES = freetype glib2

HARFBUZZ_CONF_OPTS = \
	-Dgdi=disabled \
	-Ddirectwrite=disabled \
	-Dcoretext=disabled \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dbenchmark=disabled \
	-Dicu_builtin=false \
	-Dexperimental_api=false \
	-Dfuzzer_ldflags="" \
	-Dgobject=disabled \
	-Dintrospection=disabled \
	-Dgraphite=disabled \
	-Dcairo=disabled \
	-Dicu=disabled \
	-Dfreetype=enabled \
	-Dglib=enabled

harfbuzz: | $(TARGET_DIR)
	$(call meson-package)

# -----------------------------------------------------------------------------

HOST_HARFBUZZ_DEPENDENCIES = host-freetype

# the rpath to host/lib for libfreetype.so.6 of host-freetype
HOST_HARFBUZZ_CONF_ENV = LDFLAGS="$(HOST_LDFLAGS)"

HOST_HARFBUZZ_CONF_OPTS = \
	-Dlibdir=lib \
	-Dgdi=disabled \
	-Ddirectwrite=disabled \
	-Dcoretext=disabled \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dbenchmark=disabled \
	-Dicu_builtin=false \
	-Dexperimental_api=false \
	-Dfuzzer_ldflags="" \
	-Dgobject=disabled \
	-Dintrospection=disabled \
	-Dgraphite=disabled \
	-Dcairo=disabled \
	-Dicu=disabled \
	-Dfreetype=enabled \
	-Dglib=disabled

host-harfbuzz: | $(HOST_DIR)
	$(call host-meson-package)
