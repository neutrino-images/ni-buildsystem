################################################################################
#
# hls-js
#
################################################################################

# hls-js and not hls.js: pkgname strips the last suffix off a target name
# (package/pkg-utils.mk), so the dotted name would look for HLS_VERSION
HLS_JS_VERSION = 1.7.3
HLS_JS_DIR     = hls.js-$(HLS_JS_VERSION)
HLS_JS_SOURCE  = hls.js-$(HLS_JS_VERSION).tgz
HLS_JS_SITE    = https://registry.npmjs.org/hls.js/-

# npm archives all unpack to package/, so each needs a directory of its own
HLS_JS_EXTRACT_DIR = $(HLS_JS_DIR)

HLS_JS_TARGET_DIR = $(SHARE_HTTPD)/ni-web/vendor
# the light build drops alternate audio, subtitles and encrypted media,
# none of which these lists carry, and saves 65 kB packed; .mjs and not
# the .js of the same name, a UMD bundle a module tag gets nothing from
define HLS_JS_INSTALL
	$(INSTALL) -d $(HLS_JS_TARGET_DIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		$(PKG_BUILD_DIR)/package/dist/hls.light.min.mjs \
		| gzip -9 -n -c > $(HLS_JS_TARGET_DIR)/hls.module.js.gz
endef
HLS_JS_INDIVIDUAL_HOOKS += HLS_JS_INSTALL

hls-js: | $(TARGET_DIR)
	$(call individual-package)
