################################################################################
#
# python-certifi
#
################################################################################

PYTHON_CERTIFI_VERSION = 2023.11.17
PYTHON_CERTIFI_DIR = certifi-$(PYTHON_CERTIFI_VERSION)
PYTHON_CERTIFI_SOURCE = certifi-$(PYTHON_CERTIFI_VERSION).tar.gz
PYTHON_CERTIFI_SITE = https://files.pythonhosted.org/packages/source/c/certifi

PYTHON_CERTIFI_SETUP_TYPE = setuptools

python-certifi: | $(TARGET_DIR)
	$(call python-package)
