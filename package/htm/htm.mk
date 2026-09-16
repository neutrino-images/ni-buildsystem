################################################################################
#
# htm
#
################################################################################

HTM_VERSION = 3.1.1
HTM_DIR     = htm-$(HTM_VERSION)
HTM_SOURCE  = htm-$(HTM_VERSION).tgz
HTM_SITE    = https://registry.npmjs.org/htm/-

# npm archives all unpack to package/, so each needs a directory of its own
HTM_EXTRACT_DIR = $(HTM_DIR)

HTM_TARGET_DIR = $(SHARE_HTTPD)/ni-web/vendor
define HTM_INSTALL
	$(INSTALL) -d $(HTM_TARGET_DIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		$(PKG_BUILD_DIR)/package/dist/htm.module.js \
		| gzip -9 -n -c > $(HTM_TARGET_DIR)/htm.module.js.gz
endef
HTM_INDIVIDUAL_HOOKS += HTM_INSTALL

htm: | $(TARGET_DIR)
	$(call individual-package)
