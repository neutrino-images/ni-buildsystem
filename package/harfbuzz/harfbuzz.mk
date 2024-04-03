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

HARFBUZZ_AUTORECONF = YES

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
