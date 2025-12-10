################################################################################
#
# python-sniffio
#
################################################################################

PYTHON_SNIFFIO_VERSION = 1.3.1
PYTHON_SNIFFIO_DIR = sniffio-$(PYTHON_SNIFFIO_VERSION)
PYTHON_SNIFFIO_SOURCE = sniffio-$(PYTHON_SNIFFIO_VERSION).tar.gz
PYTHON_SNIFFIO_SITE = $(PYPI_MIRROR)/s/sniffio

PYTHON_SNIFFIO_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

python-sniffio: | $(TARGET_DIR)
	$(call python-package)
