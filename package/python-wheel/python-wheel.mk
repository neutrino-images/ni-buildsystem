################################################################################
#
# python-wheel
#
################################################################################

PYTHON_WHEEL_VERSION = 0.40.0
PYTHON_WHEEL_DIR = wheel-$(PYTHON_WHEEL_VERSION)
PYTHON_WHEEL_SOURCE = wheel-$(PYTHON_WHEEL_VERSION).tar.gz
PYTHON_WHEEL_SITE = https://files.pythonhosted.org/packages/fc/ef/0335f7217dd1e8096a9e8383e1d472aa14717878ffe07c4772e68b6e8735

PYTHON_WHEEL_SETUP_TYPE = flit

python-wheel: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-wheel: | $(HOST_DIR)
	$(call host-python-package)
