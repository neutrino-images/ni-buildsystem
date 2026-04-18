################################################################################
#
# openssl
#
################################################################################

OPENSSL_DEPENDENCIES = $(if $(filter $(BOXTYPE),coolstream),libopenssl-cst,libopenssl)

openssl: | $(TARGET_DIR)
	$(call virtual-package)
