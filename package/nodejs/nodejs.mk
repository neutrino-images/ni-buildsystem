################################################################################
#
# nodejs
#
################################################################################

# host-nodejs only; the prebuilt Linux binaries of nodejs.org

NODEJS_VERSION = 22.23.5

NODEJS_HOST_ARCH := $(shell uname -m)
ifeq ($(NODEJS_HOST_ARCH),x86_64)
NODEJS_BIN_ARCH = x64
else ifeq ($(NODEJS_HOST_ARCH),aarch64)
NODEJS_BIN_ARCH = arm64
else ifeq ($(NODEJS_HOST_ARCH),armv7l)
NODEJS_BIN_ARCH = armv7l
else ifeq ($(NODEJS_HOST_ARCH),ppc64le)
NODEJS_BIN_ARCH = ppc64le
endif

NODEJS_DIR = node-v$(NODEJS_VERSION)-linux-$(NODEJS_BIN_ARCH)
NODEJS_SOURCE = node-v$(NODEJS_VERSION)-linux-$(NODEJS_BIN_ARCH).tar.xz
NODEJS_SITE = https://nodejs.org/dist/v$(NODEJS_VERSION)

define HOST_NODEJS_CHECK_ARCH
	if [ -z "$(NODEJS_BIN_ARCH)" ]; then \
		echo "host-nodejs: no prebuilt nodejs for $(NODEJS_HOST_ARCH)"; \
		exit 1; \
	fi
endef
HOST_NODEJS_PRE_DOWNLOAD_HOOKS += HOST_NODEJS_CHECK_ARCH

define HOST_NODEJS_INSTALL_CMDS
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/bin $(PKG_BUILD_DIR)/include \
		$(PKG_BUILD_DIR)/lib $(PKG_BUILD_DIR)/share $(HOST_DIR)/
endef

host-nodejs: | $(HOST_DIR)
	$(call host-generic-package,$(PKG_NO_BUILD))
