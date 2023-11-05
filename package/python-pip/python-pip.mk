################################################################################
#
# python-pip
#
################################################################################

PYTHON_PIP_VERSION = 22.3.1
PYTHON_PIP_DIR = pip-$(PYTHON_PIP_VERSION)
PYTHON_PIP_SOURCE = pip-$(PYTHON_PIP_VERSION).tar.gz
PYTHON_PIP_SITE = https://files.pythonhosted.org/packages/a3/50/c4d2727b99052780aad92c7297465af5fe6eec2dbae490aa9763273ffdc1

PYTHON_PIP_SETUP_TYPE = setuptools

python-pip: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-pip: | $(HOST_DIR)
	$(call host-python-package)
