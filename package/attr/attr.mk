################################################################################
#
# attr
#
################################################################################

ATTR_VERSION = 2.5.1
ATTR_DIR = attr-$(ATTR_VERSION)
ATTR_SOURCE = attr-$(ATTR_VERSION).tar.xz
ATTR_SITE = http://download.savannah.gnu.org/releases/attr

# -----------------------------------------------------------------------------

host-attr: | $(HOST_DIR)
	$(call host-autotools-package)
