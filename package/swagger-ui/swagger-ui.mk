################################################################################
#
# swagger-ui
#
################################################################################

SWAGGER_UI_VERSION = 5.17.14
SWAGGER_UI_DIR     = swagger-ui-dist-$(SWAGGER_UI_VERSION)
SWAGGER_UI_SOURCE  = swagger-ui-dist-$(SWAGGER_UI_VERSION).tgz
SWAGGER_UI_SITE    = https://registry.npmjs.org/swagger-ui-dist/-

# npm archives all unpack to package/, so each needs a directory of its own
SWAGGER_UI_EXTRACT_DIR = $(SWAGGER_UI_DIR)

SWAGGER_UI_TARGET_DIR = $(SHARE_HTTPD)/ni-web/swagger/vendor
# stored compressed: the server inflates for a caller that took none
define SWAGGER_UI_INSTALL
	$(INSTALL) -d $(SWAGGER_UI_TARGET_DIR)
	gzip -9 -n -c $(PKG_BUILD_DIR)/package/swagger-ui-bundle.js \
		> $(SWAGGER_UI_TARGET_DIR)/swagger-ui-bundle.js.gz
	gzip -9 -n -c $(PKG_BUILD_DIR)/package/swagger-ui.css \
		> $(SWAGGER_UI_TARGET_DIR)/swagger-ui.css.gz
endef
SWAGGER_UI_INDIVIDUAL_HOOKS += SWAGGER_UI_INSTALL

swagger-ui: | $(TARGET_DIR)
	$(call individual-package)
