################################################################################
#
# gettext
#
################################################################################

GETTEXT_VERSION = 0.19.8.1
GETTEXT_DIR = gettext-$(GETTEXT_VERSION)
GETTEXT_SOURCE = gettext-$(GETTEXT_VERSION).tar.xz
GETTEXT_SITE = $(GNU_MIRROR)/gettext

GETTEXT_AUTORECONF = YES

GETTEXT_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs

GETTEXT_MAKE_OPTS = \
	-C gettext-runtime

gettext: | $(TARGET_DIR)
	$(call autotools-package)

# ------------------------------------------------------------------------------

HOST_GETTEXT_VERSION = 0.22.4
HOST_GETTEXT_DIR = gettext-$(HOST_GETTEXT_VERSION)
HOST_GETTEXT_SOURCE = gettext-$(HOST_GETTEXT_VERSION).tar.xz
HOST_GETTEXT_SITE = $(GNU_MIRROR)/gettext

# Avoid using the bundled subset of libxml2
HOST_GETTEXT_DEPENDENCIES = host-libxml2

HOST_GETTEXT_CONF_OPTS = \
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-rpath \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs

# Disable the build of documentation and examples of gettext-tools,
# and the build of documentation and tests of gettext-runtime.
define HOST_GETTEXT_DISABLE_UNNEEDED
	$(SED) '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/examples$$//' $(PKG_BUILD_DIR)/gettext-tools/Makefile.in
	$(SED) '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/tests$$//' $(PKG_BUILD_DIR)/gettext-runtime/Makefile.in
endef
HOST_GETTEXT_POST_PATCH_HOOKS += HOST_GETTEXT_DISABLE_UNNEEDED

# Disable interactive confirmation in host gettextize for package fixups
define HOST_GETTEXT_GETTEXTIZE_CONFIRMATION
	$(SED) '/read dummy/d' $(HOST_DIR)/bin/gettextize
endef
HOST_GETTEXT_POST_INSTALL_HOOKS += HOST_GETTEXT_GETTEXTIZE_CONFIRMATION

# gettext-tools require libtextstyle.m4
define HOST_GETTEXT_INSTALL_LIBTEXTSTYLE_M4
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/libtextstyle/m4/libtextstyle.m4 $(ACLOCAL_HOST_DIR)/libtextstyle.m4
endef
HOST_GETTEXT_POST_INSTALL_HOOKS += HOST_GETTEXT_INSTALL_LIBTEXTSTYLE_M4

host-gettext: | $(HOST_DIR)
	$(call host-autotools-package)
