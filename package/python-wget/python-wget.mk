################################################################################
#
# python-wget
#
################################################################################

PYTHON_WGET_VERSION = 3.2
PYTHON_WGET_DIR = wget-$(PYTHON_WGET_VERSION)
PYTHON_WGET_SOURCE = wget-$(PYTHON_WGET_VERSION).zip
PYTHON_WGET_SITE = $(PYPI_MIRROR)/w/wget

PYTHON_WGET_SETUP_TYPE = pep517

python-wget: | $(TARGET_DIR)
	$(call python-package)
