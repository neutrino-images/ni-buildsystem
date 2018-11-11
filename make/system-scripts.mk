#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	init-helpers \
	init-camd

init-helpers: $(ETCINITD)
	install -m 0644 $(IMAGEFILES)/scripts/init.globals $(ETCINITD)/globals
	install -m 0644 $(IMAGEFILES)/scripts/init.functions $(ETCINITD)/functions

init-camd: $(ETCINITD)
	install -m 0755 $(IMAGEFILES)/scripts/camd.init $(ETCINITD)/camd
	install -m 0755 $(IMAGEFILES)/scripts/camd_datefix.init $(ETCINITD)/camd_datefix
	set -e; cd $(ETCINITD); \
		ln -sf camd S99camd; \
		ln -sf camd K01camd

# -----------------------------------------------------------------------------

scripts: $(SBIN)
	install -m 0755 $(IMAGEFILES)/scripts/service $(SBIN)
ifeq ($(BOXTYPE), coolstream)
	install -m 0755 $(IMAGEFILES)/scripts/flash_eraseall $(SBIN)
endif
