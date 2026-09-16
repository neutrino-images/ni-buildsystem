################################################################################
#
# mpegts-js
#
################################################################################

MPEGTS_JS_VERSION = 1.8.2
MPEGTS_JS_DIR     = mpegts.js-$(MPEGTS_JS_VERSION)
MPEGTS_JS_SOURCE  = mpegts.js-$(MPEGTS_JS_VERSION).tgz
MPEGTS_JS_SITE    = https://registry.npmjs.org/mpegts.js/-

# npm archives all unpack to package/, so each needs a directory of its own
MPEGTS_JS_EXTRACT_DIR = $(MPEGTS_JS_DIR)

MPEGTS_JS_TARGET_DIR = $(SHARE_HTTPD)/ni-web/vendor
# UMD, so the page loads it with a script element when somebody presses play
define MPEGTS_JS_INSTALL
	$(INSTALL) -d $(MPEGTS_JS_TARGET_DIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		$(PKG_BUILD_DIR)/package/dist/mpegts.js \
		| gzip -9 -n -c > $(MPEGTS_JS_TARGET_DIR)/mpegts.js.gz
endef
MPEGTS_JS_INDIVIDUAL_HOOKS += MPEGTS_JS_INSTALL

mpegts-js: | $(TARGET_DIR)
	$(call individual-package)
