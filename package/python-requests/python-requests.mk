################################################################################
#
# python-requests
#
################################################################################

PYTHON_REQUESTS_VERSION = 2.31.0
PYTHON_REQUESTS_DIR = requests-$(PYTHON_REQUESTS_VERSION)
PYTHON_REQUESTS_SOURCE = requests-$(PYTHON_REQUESTS_VERSION).tar.gz
PYTHON_REQUESTS_SITE = https://files.pythonhosted.org/packages/source/r/requests

PYTHON_REQUESTS_SETUP_TYPE = setuptools

python-requests: | $(TARGET_DIR)
	$(call python-package)
