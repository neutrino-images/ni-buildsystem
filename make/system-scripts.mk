#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	init-camd

init-camd: $(ETCINITD)
	install -m755 $(IMAGEFILES)/scripts/camd.init $(ETCINITD)/camd
	install -m755 $(IMAGEFILES)/scripts/camd_datefix.init $(ETCINITD)/camd_datefix
	set -e; cd $(ETCINITD); \
		ln -sf camd S99camd; \
		ln -sf camd K01camd

# -----------------------------------------------------------------------------

scripts: $(SBIN)
	install -m755 $(IMAGEFILES)/scripts/service $(SBIN)
ifeq ($(BOXTYPE), coolstream)
	install -m755 $(IMAGEFILES)/scripts/flash_eraseall $(SBIN)
endif
