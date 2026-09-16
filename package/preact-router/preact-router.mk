################################################################################
#
# preact-router
#
################################################################################

PREACT_ROUTER_VERSION = 4.1.2
PREACT_ROUTER_DIR     = preact-router-$(PREACT_ROUTER_VERSION)
PREACT_ROUTER_SOURCE  = preact-router-$(PREACT_ROUTER_VERSION).tgz
PREACT_ROUTER_SITE    = https://registry.npmjs.org/preact-router/-

# npm archives all unpack to package/, so each needs a directory of its own
PREACT_ROUTER_EXTRACT_DIR = $(PREACT_ROUTER_DIR)

PREACT_ROUTER_TARGETDIR = $(SHARE_HTTPD)/ni-web/vendor
# the closing quote in each pattern is what keeps the two names apart, not
# their order: without it the shorter one eats the prefix of the longer
define PREACT_ROUTER_INSTALL
	$(INSTALL) -d $(PREACT_ROUTER_TARGETDIR)
	sed -e '/^\/\/# sourceMappingURL=/d' \
		-e 's|from"preact/hooks"|from"/vendor/hooks.module.js"|g' \
		-e 's|from"preact"|from"/vendor/preact.module.js"|g' \
		$(PKG_BUILD_DIR)/package/dist/preact-router.module.js \
		| gzip -9 -n -c > $(PREACT_ROUTER_TARGETDIR)/preact-router.module.js.gz
endef
PREACT_ROUTER_INDIVIDUAL_HOOKS += PREACT_ROUTER_INSTALL

preact-router: | $(TARGET_DIR)
	$(call individual-package)
