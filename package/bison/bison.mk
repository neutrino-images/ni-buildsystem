################################################################################
#
# bison
#
################################################################################

BISON_VERSION = 3.8.2
BISON_DIR = bison-$(BISON_VERSION)
BISON_SOURCE = bison-$(BISON_VERSION).tar.xz
BISON_SITE = $(GNU_MIRROR)/bison

# -----------------------------------------------------------------------------

HOST_BISON_DEPENDENCIES = host-m4

HOST_BISON_CONF_ENV = \
	ac_cv_libtextstyle=no

HOST_BISON_CONF_OPTS = \
	--enable-relocatable

# parallel build issue in examples/c/reccalc/
HOST_BISON_MAKE = \
	$(MAKE1)

host-bison: | $(HOST_DIR)
	$(call host-autotools-package)
