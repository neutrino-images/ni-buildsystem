################################################################################
#
# python-mutagen
#
################################################################################

PYTHON_MUTAGEN_VERSION = 1.46.0
PYTHON_MUTAGEN_DIR = mutagen-$(PYTHON_MUTAGEN_VERSION)
PYTHON_MUTAGEN_SOURCE = mutagen-$(PYTHON_MUTAGEN_VERSION).tar.gz
PYTHON_MUTAGEN_SITE = https://files.pythonhosted.org/packages/b1/54/d1760a363d0fe345528e37782f6c18123b0e99e8ea755022fd51f1ecd0f9

PYTHON_MUTAGEN_SETUP_TYPE = setuptools

define PYTHON_MUTAGEN_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_mandir)
endef
PYTHON_MUTAGEN_TARGET_FINALIZE_HOOKS += PYTHON_MUTAGEN_TARGET_CLEANUP

python-mutagen: | $(TARGET_DIR)
	$(call python-package)
