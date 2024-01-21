################################################################################
#
# python-wheel
#
################################################################################

PYTHON_WHEEL_VERSION = 0.42.0
PYTHON_WHEEL_DIR = wheel-$(PYTHON_WHEEL_VERSION)
PYTHON_WHEEL_SOURCE = wheel-$(PYTHON_WHEEL_VERSION).tar.gz
PYTHON_WHEEL_SITE = https://files.pythonhosted.org/packages/source/w/wheel

PYTHON_WHEEL_SETUP_TYPE = flit

python-wheel: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-wheel: | $(HOST_DIR)
	$(call host-python-package)
