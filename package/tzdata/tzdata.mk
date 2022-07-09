################################################################################
#
# tzdata
#
################################################################################

TZDATA_VERSION = 2022a
TZDATA_DIR = tzdata$(TZDATA_VERSION)
TZDATA_SOURCE = tzdata$(TZDATA_VERSION).tar.gz
TZDATA_SITE = https://data.iana.org/time-zones/releases

TZDATA_DEPENDENCIES = host-zic

# fix non-existing subdir in tzdata tarball
TZDATA_EXTRACT_DIR = $($(PKG)_DIR)

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica etcetera backward factory

define TZDATA_BUILD_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		$(HOST_ZIC) -b fat -d zoneinfo.tmp $(TZDATA_ZONELIST)
endef

define TZDATA_INSTALL_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(PKG_FILES_DIR)/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				test -e $$y && $(INSTALL_DATA) -D $$y $(TARGET_datadir)/zoneinfo/$$x; \
			done; \
		done
endef

TZDATA_LOCALTIME = CET

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION),yes),/var/etc/localtime,/etc/localtime)

define TZDATA_INSTALL_ETC_LOCALTIME
	ln -sf $(datadir)/zoneinfo/$(TZDATA_LOCALTIME) $(TARGET_DIR)$(ETC_LOCALTIME)
endef
TZDATA_TARGET_FINALIZE_HOOKS += TZDATA_INSTALL_ETC_LOCALTIME

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
define TZDATA_INSTALL_ETC_LOCALTIME_LINK
	ln -sf $(ETC_LOCALTIME) $(TARGET_sysconfdir)/localtime
endef
TZDATA_TARGET_FINALIZE_HOOKS += TZDATA_INSTALL_ETC_LOCALTIME_LINK
endif

define TZDATA_INSTALL_TIMEZONE_FILES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/timezone.xml $(TARGET_sysconfdir)/timezone.xml
	echo "$(TZDATA_LOCALTIME)" > $(TARGET_sysconfdir)/timezone
endef
TZDATA_TARGET_FINALIZE_HOOKS += TZDATA_INSTALL_TIMEZONE_FILES

define TZDATA_INSTALL_PROFILE_D_SCRIPT
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export TZ=\$$(cat $(sysconfdir)/timezone)" > $(TARGET_sysconfdir)/profile.d/tz.sh
endef
TZDATA_TARGET_FINALIZE_HOOKS += TZDATA_INSTALL_PROFILE_D_SCRIPT

tzdata: | $(TARGET_DIR)
	$(call generic-package)
