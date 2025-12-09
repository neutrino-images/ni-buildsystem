################################################################################
#
# python-pycryptodome
#
################################################################################

PYTHON_PYCRYPTODOME_VERSION = 3.23.0
PYTHON_PYCRYPTODOME_DIR = pycryptodome-$(PYTHON_PYCRYPTODOMEX_VERSION)
PYTHON_PYCRYPTODOME_SOURCE = pycryptodome-$(PYTHON_PYCRYPTODOMEX_VERSION).tar.gz
PYTHON_PYCRYPTODOME_SITE = $(PYPI_MIRROR)/p/pycryptodome

PYTHON_PYCRYPTODOME_SETUP_TYPE = setuptools

python-pycryptodome: | $(TARGET_DIR)
	$(call python-package)
