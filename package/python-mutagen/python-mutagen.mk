################################################################################
#
# python-mutagen
#
################################################################################

PYTHON_MUTAGEN_VERSION = 1.47.0
PYTHON_MUTAGEN_DIR = mutagen-$(PYTHON_MUTAGEN_VERSION)
PYTHON_MUTAGEN_SOURCE = mutagen-$(PYTHON_MUTAGEN_VERSION).tar.gz
PYTHON_MUTAGEN_SITE = https://files.pythonhosted.org/packages/source/m/mutagen

PYTHON_MUTAGEN_SETUP_TYPE = setuptools

define PYTHON_MUTAGEN_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_mandir)
endef
PYTHON_MUTAGEN_TARGET_FINALIZE_HOOKS += PYTHON_MUTAGEN_TARGET_CLEANUP

python-mutagen: | $(TARGET_DIR)
	$(call python-package)
