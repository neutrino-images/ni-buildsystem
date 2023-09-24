################################################################################
#
# python
#
################################################################################

PYTHON_LIB_DIR = $(TARGET_libdir)/python$(PYTHON3_VERSION_MAJOR)
PYTHON_INCLUDE_DIR = $(TARGET_includedir)/python$(PYTHON3_VERSION_MAJOR)
PYTHON_SITE_PACKAGES_DIR = $(PYTHON_LIB_DIR)/site-packages
PYTHON_PATH = $(PYTHON_LIB_DIR)

# ------------------------------------------------------------------------------

HOST_PYTHON_BINARY = $(HOST_DIR)/bin/python3

HOST_PYTHON_LIB_DIR = $(HOST_DIR)/lib/python$(PYTHON3_VERSION_MAJOR)
HOST_PYTHON_INCLUDE_DIR = $(HOST_DIR)/include/python$(PYTHON3_VERSION_MAJOR)
HOST_PYTHON_SITE_PACKAGES_DIR = $(HOST_PYTHON_LIB_DIR)/site-packages
HOST_PYTHON_PATH = $(HOST_PYTHON_LIB_DIR)
