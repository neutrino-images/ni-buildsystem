################################################################################
#
# openssl
#
################################################################################

OPENSSL_DEPENDENCIES = $(if $(filter $(BOXTYPE),coolstream),libopenssl1,libopenssl)

openssl: | $(TARGET_DIR)
	$(call virtual-package)
