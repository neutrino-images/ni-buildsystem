################################################################################
#
# Python packages
#
################################################################################

HOST_PYTHON3_ENV = \
	CC="$(HOSTCC)" \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_SITEPACKAGES_DIR)

HOST_PYTHON3_OPTS = \
	$(if $(VERBOSE),,-q)

define HOST_PYTHON3_BUILD
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_PYTHON3_ENV) \
		$(HOST_PYTHON3_BINARY) ./setup.py build --executable=/usr/bin/python \
		$(HOST_PYTHON3_OPTS)
endef

define HOST_PYTHON3_INSTALL
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_PYTHON3_ENV) \
		$(HOST_PYTHON3_BINARY) ./setup.py install --root=$(HOST_DIR) --prefix= \
		$(HOST_PYTHON3_OPTS)
endef

# -----------------------------------------------------------------------------

define host-python3-package
	$(call PREPARE)
	$(call HOST_PYTHON3_BUILD)
	$(call HOST_PYTHON3_INSTALL)
	$(call HOST_FOLLOWUP)
endef
