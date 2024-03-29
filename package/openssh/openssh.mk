################################################################################
#
# openssh
#
################################################################################

OPENSSH_VERSION = $(if $(filter $(BOXTYPE),coolstream),9.3p2,9.4p1)
OPENSSH_DIR = openssh-$(OPENSSH_VERSION)
OPENSSH_SOURCE = openssh-$(OPENSSH_VERSION).tar.gz
OPENSSH_SITE = https://artfiles.org/openbsd/OpenSSH/portable

OPENSSH_DEPENDENCIES = openssl zlib

OPENSSH_CONF_ENV = \
	ac_cv_search_dlopen=no

OPENSSH_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--sysconfdir=$(sysconfdir)/ssh \
	--with-pid-dir=/var/run \
	--with-privsep-path=/var/empty \
	--with-cppflags="-pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) -I$(TARGET_includedir)" \
	--with-ldflags="-L$(TARGET_libdir)" \
	--without-bsd-auth \
	--without-kerberos5 \
	--without-sandbox \
	--disable-strip \
	--disable-lastlog \
	--disable-utmp \
	--disable-utmpx \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-pututline \
	--disable-pututxline

openssh: | $(TARGET_DIR)
	$(call autotools-package)
