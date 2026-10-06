################################################################################
#
# qrcode-generator
#
################################################################################

# version also named in yweb-devenv/scripts/fetch-webui-vendor.sh and ni-neutrino/test/web/fetch-types.sh
QRCODE_GENERATOR_VERSION = 2.0.4
QRCODE_GENERATOR_DIR = qrcode-generator-$(QRCODE_GENERATOR_VERSION)
QRCODE_GENERATOR_SOURCE = qrcode-generator-$(QRCODE_GENERATOR_VERSION).tgz
QRCODE_GENERATOR_SITE = https://registry.npmjs.org/qrcode-generator/-

# npm archives all unpack to package/, so each needs a directory of its own
QRCODE_GENERATOR_EXTRACT_DIR = $(QRCODE_GENERATOR_DIR)

QRCODE_GENERATOR_TARGET_DIR = $(SHARE_HTTPD)/ni-web/vendor
# qrcode.mjs, not qrcode.js (UMD, no export)
define QRCODE_GENERATOR_INSTALL
	$(INSTALL) -d $(QRCODE_GENERATOR_TARGET_DIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		$(PKG_BUILD_DIR)/package/dist/qrcode.mjs \
		| gzip -9 -n -c > $(QRCODE_GENERATOR_TARGET_DIR)/qrcode.module.js.gz
endef
QRCODE_GENERATOR_INDIVIDUAL_HOOKS += QRCODE_GENERATOR_INSTALL

qrcode-generator: | $(TARGET_DIR)
	$(call individual-package)
