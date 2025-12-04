################################################################################
#
# python-wheel
#
################################################################################

PYTHON_WHEEL_VERSION = 0.45.1
PYTHON_WHEEL_DIR = wheel-$(PYTHON_WHEEL_VERSION)
PYTHON_WHEEL_SOURCE = wheel-$(PYTHON_WHEEL_VERSION).tar.gz
PYTHON_WHEEL_SITE = $(PYPI_MIRROR)/w/wheel

PYTHON_WHEEL_SETUP_TYPE = flit

python-wheel: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-wheel: | $(HOST_DIR)
	$(call host-python-package)
