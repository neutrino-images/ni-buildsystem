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
