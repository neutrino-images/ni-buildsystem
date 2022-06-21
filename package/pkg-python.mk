################################################################################
#
# Python packages
#
################################################################################

HOST_PYTHON3_BUILD = \
	CC="$(HOSTCC)" \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_LIB_DIR)/site-packages \
	$(HOST_PYTHON3_BINARY) ./setup.py -q build --executable=/usr/bin/python

HOST_PYTHON3_INSTALL = \
	CC="$(HOSTCC)" \
	CFLAGS="$(HOST_CFLAGS)" \
	LDFLAGS="$(HOST_LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_LIB_DIR)/site-packages \
	$(HOST_PYTHON3_BINARY) ./setup.py -q install --root=$(HOST_DIR) --prefix=

#define python3-package
#	$(call PREPARE)
#	$(CHDIR)/$($(PKG)_DIR); \
#		$(PYTHON3_BUILD); \
#		$(PYTHON3_INSTALL)
#	$(call TARGET_FOLLOWUP)
#endef

define host-python3-package
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_PYTHON3_BUILD); \
		$(HOST_PYTHON3_INSTALL)
	$(call HOST_FOLLOWUP)
endef
