################################################################################
#
# ntp
#
################################################################################

NTP_VERSION = 4.2.8p18
NTP_DIR = ntp-$(NTP_VERSION)
NTP_SOURCE = ntp-$(NTP_VERSION).tar.gz
NTP_SITE = https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-$(basename $(NTP_VERSION))

NTP_DEPENDENCIES = libevent openssl

# 0001-ntp-syscalls-fallback.patch
NTP_AUTORECONF = YES

NTP_CONF_ENV = \
	ac_cv_lib_md5_MD5Init=no \
	POSIX_SHELL=/bin/sh

NTP_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datadir=$(REMOVE_datadir) \
	--libexecdir=$(REMOVE_libexecdir) \
	--docdir=$(REMOVE_docdir) \
	--program-transform-name=s,,, \
	--disable-ATOM \
	--disable-SHM \
	--disable-tickadj \
	--disable-debugging \
	--disable-linuxcaps \
	--disable-local-libevent \
	--with-shared \
	--with-crypto --enable-openssl-random --enable-verbose-ssl \
	--with-hardenfile=linux \
	--with-yielding-select=yes \
	--without-sntp \
	--without-ntpsnmpd \
	--without-lineeditlibs

define NTP_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,calc_tickadj ntp-keygen ntp-wait ntpd ntptime tickadj update-leap)
endef
NTP_TARGET_FINALIZE_HOOKS += NTP_TARGET_CLEANUP

define NTP_INSTALL_NTPDATE_INIT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/ntpdate.init $(TARGET_sysconfdir)/init.d/ntpdate
endef
NTP_TARGET_FINALIZE_HOOKS += NTP_INSTALL_NTPDATE_INIT

ntp: | $(TARGET_DIR)
	$(call autotools-package)
