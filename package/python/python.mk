################################################################################
#
# python
#
################################################################################

PYTHON_DEPENDENCIES = python3

python: | $(TARGET_DIR)
	$(call virtual-package)

# -----------------------------------------------------------------------------

HOST_PYTHON_DEPENDENCIES = host-python3

host-python: | $(TARGET_DIR)
	$(call host-virtual-package)
