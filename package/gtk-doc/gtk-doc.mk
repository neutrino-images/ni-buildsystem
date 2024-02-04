################################################################################
#
# gtk-doc
#
################################################################################

GTK_DOC_VERSION_MAJOR = 1.33
GTK_DOC_VERSION = $(GTK_DOC_VERSION_MAJOR).2
GTK_DOC_DIR = gtk-doc-$(GTK_DOC_VERSION)
GTK_DOC_SOURCE = gtk-doc-$(GTK_DOC_VERSION).tar.xz
GTK_DOC_SITE = https://download.gnome.org/sources/gtk-doc/$(GTK_DOC_VERSION_MAJOR)

# -----------------------------------------------------------------------------

HOST_GTK_DOC_DEPENDENCIES = host-libxslt

host-gtk-doc: | $(HOST_DIR)
	$(call host-autotools-package)
