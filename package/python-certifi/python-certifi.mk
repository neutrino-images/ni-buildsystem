################################################################################
#
# python-certifi
#
################################################################################

PYTHON_CERTIFI_VERSION = 2023.7.22
PYTHON_CERTIFI_DIR = certifi-$(PYTHON_CERTIFI_VERSION)
PYTHON_CERTIFI_SOURCE = certifi-$(PYTHON_CERTIFI_VERSION).tar.gz
PYTHON_CERTIFI_SITE = https://files.pythonhosted.org/packages/98/98/c2ff18671db109c9f10ed27f5ef610ae05b73bd876664139cf95bd1429aa

PYTHON_CERTIFI_SETUP_TYPE = setuptools

python-certifi: | $(TARGET_DIR)
	$(call python-package)
