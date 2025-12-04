################################################################################
#
# python-certifi
#
################################################################################

PYTHON_CERTIFI_VERSION = 2025.11.12
PYTHON_CERTIFI_DIR = certifi-$(PYTHON_CERTIFI_VERSION)
PYTHON_CERTIFI_SOURCE = certifi-$(PYTHON_CERTIFI_VERSION).tar.gz
PYTHON_CERTIFI_SITE = $(PYPI_MIRROR)/c/certifi

PYTHON_CERTIFI_SETUP_TYPE = setuptools

python-certifi: | $(TARGET_DIR)
	$(call python-package)
