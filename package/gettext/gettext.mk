################################################################################
#
# gettext
#
################################################################################

GETTEXT_VERSION = 0.19.8.1
GETTEXT_DIR = gettext-$(GETTEXT_VERSION)
GETTEXT_SOURCE = gettext-$(GETTEXT_VERSION).tar.xz
GETTEXT_SITE = $(GNU_MIRROR)/gettext

$(DL_DIR)/$(GETTEXT_SOURCE):
	$(download) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

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

gettext: $(DL_DIR)/$(GETTEXT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call TARGET_CONFIGURE)
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE) -C gettext-runtime; \
		$(MAKE) -C gettext-runtime install DESTDIR=$(TARGET_DIR)
	$(call REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
