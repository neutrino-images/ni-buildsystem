################################################################################
#
# preact
#
################################################################################

PREACT_VERSION = 10.24.3
PREACT_DIR     = preact-$(PREACT_VERSION)
PREACT_SOURCE  = preact-$(PREACT_VERSION).tgz
PREACT_SITE    = https://registry.npmjs.org/preact/-

# npm archives all unpack to package/, so each needs a directory of its own
PREACT_EXTRACT_DIR = $(PREACT_DIR)

PREACT_TARGET_DIR = $(SHARE_HTTPD)/ni-web/vendor
# preact.module.js and not preact.min.module.js: the minified one exports
# nothing and assigns to self.preact instead
# hooks imports the bare name "preact", which no browser resolves without
# an import map, so it is rewritten to the address the page serves it at
define PREACT_INSTALL
	$(INSTALL) -d $(PREACT_TARGET_DIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		$(PKG_BUILD_DIR)/package/dist/preact.module.js \
		| gzip -9 -n -c > $(PREACT_TARGET_DIR)/preact.module.js.gz
	sed -e '/^\/\/# sourceMappingURL=/d' \
		-e 's|from"preact"|from"/vendor/preact.module.js"|g' \
		$(PKG_BUILD_DIR)/package/hooks/dist/hooks.module.js \
		| gzip -9 -n -c > $(PREACT_TARGET_DIR)/hooks.module.js.gz
endef
PREACT_INDIVIDUAL_HOOKS += PREACT_INSTALL

preact: | $(TARGET_DIR)
	$(call individual-package)
