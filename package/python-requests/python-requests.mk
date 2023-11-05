################################################################################
#
# python-requests
#
################################################################################

PYTHON_REQUESTS_VERSION = 2.31.0
PYTHON_REQUESTS_DIR = requests-$(PYTHON_REQUESTS_VERSION)
PYTHON_REQUESTS_SOURCE = requests-$(PYTHON_REQUESTS_VERSION).tar.gz
PYTHON_REQUESTS_SITE = https://files.pythonhosted.org/packages/9d/be/10918a2eac4ae9f02f6cfe6414b7a155ccd8f7f9d4380d62fd5b955065c3

PYTHON_REQUESTS_SETUP_TYPE = setuptools

python-requests: | $(TARGET_DIR)
	$(call python-package)
