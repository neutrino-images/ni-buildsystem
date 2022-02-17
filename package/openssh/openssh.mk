################################################################################
#
# openssh
#
################################################################################

OPENSSH_VERSION = 8.6p1
OPENSSH_DIR = openssh-$(OPENSSH_VERSION)
OPENSSH_SOURCE = openssh-$(OPENSSH_VERSION).tar.gz
OPENSSH_SITE = https://artfiles.org/openbsd/OpenSSH/portable

$(DL_DIR)/$(OPENSSH_SOURCE):
	$(download) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

OPENSSH_DEPENDENCIES = openssl zlib

OPENSSH_CONF_ENV = \
	ac_cv_search_dlopen=no

OPENSSH_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--sysconfdir=$(sysconfdir)/ssh \
	--libexecdir=$(sbindir) \
	--with-pid-dir=/tmp \
	--with-privsep-path=/var/empty \
	--with-cppflags="-pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) -I$(TARGET_includedir)" \
	--with-ldflags="-L$(TARGET_libdir)" \
	--disable-strip \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-pututline \
	--disable-pututxline

openssh: $(OPENSSH_DEPENDENCIES) $(DL_DIR)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_CONF_ENV) ./configure $(TARGET_CONFIGURE_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
