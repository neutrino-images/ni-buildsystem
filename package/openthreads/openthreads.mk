################################################################################
#
# openthreads
#
################################################################################

OPENTHREADS_VERSION = ni-git
OPENTHREADS_DIR = $(NI_OPENTHREADS)
OPENTHREADS_SOURCE = $(NI_OPENTHREADS)
OPENTHREADS_SITE = https://github.com/neutrino-images

OPENTHREADS_CONF_OPTS = \
	-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE__TRYRUN_OUTPUT="1"

openthreads: | $(TARGET_DIR)
	$(call cmake-package)
