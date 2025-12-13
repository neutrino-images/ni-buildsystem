################################################################################
#
# python-zstd
#
################################################################################

PYTHON_ZSTD_VERSION = 1.5.7.2
PYTHON_ZSTD_DIR = zstd-$(PYTHON_ZSTD_VERSION)
PYTHON_ZSTD_SOURCE = zstd-$(PYTHON_ZSTD_VERSION).tar.gz
PYTHON_ZSTD_SITE = $(PYPI_MIRROR)/z/zstd

PYTHON_ZSTD_SETUP_TYPE = setuptools

python-zstd: | $(TARGET_DIR)
	$(call python-package)
