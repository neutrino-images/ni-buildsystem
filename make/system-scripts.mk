#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	init-helpers \
	init-coredump \
	init-crond \
	init-inetd \
	init-hostname \
	init-camd

init-helpers: $(ETCINITD)
	install -m 0644 $(IMAGEFILES)/scripts/init.globals $(ETCINITD)/globals
	install -m 0644 $(IMAGEFILES)/scripts/init.functions $(ETCINITD)/functions

init-hostname: $(ETCINITD)
	install -m 0755 $(IMAGEFILES)/scripts/hostname.init $(ETCINITD)/hostname

init-coredump: $(ETCINITD)
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
	install -m 0755 $(IMAGEFILES)/scripts/coredump.init $(ETCINITD)/coredump
endif

init-crond: $(ETCINITD)
	install -m 0755 $(IMAGEFILES)/scripts/crond.init $(ETCINITD)/crond

init-inetd: $(ETCINITD)
	install -m 0755 $(IMAGEFILES)/scripts/inetd.init $(ETCINITD)/inetd

init-camd: $(ETCINITD)
	install -m 0755 $(IMAGEFILES)/scripts/camd.init $(ETCINITD)/camd
	install -m 0755 $(IMAGEFILES)/scripts/camd_datefix.init $(ETCINITD)/camd_datefix
	$(CD) $(ETCINITD); \
		ln -sf camd S99camd; \
		ln -sf camd K01camd

# -----------------------------------------------------------------------------

scripts: $(SBIN)
	install -m 0755 $(IMAGEFILES)/scripts/service $(SBIN)
ifeq ($(BOXTYPE), coolstream)
	install -m 0755 $(IMAGEFILES)/scripts/flash_eraseall $(SBIN)
endif
	install -D -m 0755 $(IMAGEFILES)/scripts/udhcpc-default.script $(TARGET_DIR)/share/udhcpc/default.script
