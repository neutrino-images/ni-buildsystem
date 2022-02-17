################################################################################
#
# tzdata
#
################################################################################

TZDATA_VERSION = 2020f
TZDATA_DIR = tzdata$(TZDATA_VERSION)
TZDATA_SOURCE = tzdata$(TZDATA_VERSION).tar.gz
TZDATA_SITE = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(TZDATA_SOURCE):
	$(download) $(TZDATA_SITE)/$(TZDATA_SOURCE)

TZDATA_DEPENDENCIES = host-zic

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica etcetera backward factory

TZDATA_LOCALTIME = CET

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION),yes),/var/etc/localtime,/etc/localtime)

tzdata: $(TZDATA_DEPENDENCIES) $(DL_DIR)/$(TZDATA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(MKDIR)/$(PKG_DIR)
	$(CHDIR)/$(PKG_DIR); \
		tar -xf $(DL_DIR)/$(PKG_SOURCE); \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		$(HOST_ZIC) -b fat -d zoneinfo.tmp $(TZDATA_ZONELIST); \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(PKG_FILES_DIR)/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				test -e $$y && $(INSTALL_DATA) -D $$y $(TARGET_datadir)/zoneinfo/$$x; \
			done; \
		done; \
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/timezone.xml $(TARGET_sysconfdir)/timezone.xml
	ln -sf $(datadir)/zoneinfo/$(TZDATA_LOCALTIME) $(TARGET_DIR)$(ETC_LOCALTIME)
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	ln -sf $(ETC_LOCALTIME) $(TARGET_sysconfdir)/localtime
  endif
	echo "$(TZDATA_LOCALTIME)" > $(TARGET_sysconfdir)/timezone
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export TZ=\$$(cat $(sysconfdir)/timezone)" > $(TARGET_sysconfdir)/profile.d/tz.sh
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
