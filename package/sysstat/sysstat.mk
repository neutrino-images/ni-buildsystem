################################################################################
#
# sysstat
#
################################################################################

SYSSTAT_VERSION = 12.7.4
SYSSTAT_DIR = sysstat-$(SYSSTAT_VERSION)
SYSSTAT_SOURCE = sysstat-$(SYSSTAT_VERSION).tar.xz
SYSSTAT_SITE = https://sysstat.github.io/sysstat-packages

SYSSTAT_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--disable-documentation \
	--disable-file-attr \
	--disable-largefile \
	--disable-sensors \
	--disable-nls \
	conf_dir="$(sysconfdir)/sysstat" \
	sa_lib_dir="$(libdir)/sa"

define SYSSTAT_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_localstatedir)/log
endef
SYSSTAT_TARGET_FINALIZE_HOOKS += SYSSTAT_TARGET_CLEANUP

sysstat: | $(TARGET_DIR)
	$(call autotools-package)
