################################################################################
#
# python-wheel
#
################################################################################

PYTHON_WHEEL_VERSION = 0.48.0
PYTHON_WHEEL_DIR = wheel-$(PYTHON_WHEEL_VERSION)
PYTHON_WHEEL_SOURCE = wheel-$(PYTHON_WHEEL_VERSION).tar.gz
PYTHON_WHEEL_SITE = $(PYPI_MIRROR)/w/wheel

PYTHON_WHEEL_SETUP_TYPE = flit

python-wheel: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

HOST_PYTHON_WHEEL_DEPENDENCIES = host-python-packaging

host-python-wheel: | $(HOST_DIR)
	$(call host-python-package)
