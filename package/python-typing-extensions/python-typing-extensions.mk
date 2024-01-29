################################################################################
#
# python-typing-extensions
#
################################################################################

PYTHON_TYPING_EXTENSIONS_VERSION = 4.9.0
PYTHON_TYPING_EXTENSIONS_DIR = typing_extensions-$(PYTHON_TYPING_EXTENSIONS_VERSION)
PYTHON_TYPING_EXTENSIONS_SOURCE = typing_extensions-$(PYTHON_TYPING_EXTENSIONS_VERSION).tar.gz
PYTHON_TYPING_EXTENSIONS_SITE = https://files.pythonhosted.org/packages/source/t/typing_extensions

PYTHON_TYPING_EXTENSIONS_SETUP_TYPE = flit

python-typing-extensions: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-typing-extensions: | $(HOST_DIR)
	$(call host-python-package)
