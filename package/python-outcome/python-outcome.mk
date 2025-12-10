################################################################################
#
# python-outcome
#
################################################################################

PYTHON_OUTCOME_VERSION = 1.3.0.post0
PYTHON_OUTCOME_DIR = outcome-$(PYTHON_OUTCOME_VERSION)
PYTHON_OUTCOME_SOURCE = outcome-$(PYTHON_OUTCOME_VERSION).tar.gz
PYTHON_OUTCOME_SITE = $(PYPI_MIRROR)/o/outcome

PYTHON_OUTCOME_SETUP_TYPE = setuptools

python-outcome: | $(TARGET_DIR)
	$(call python-package)
