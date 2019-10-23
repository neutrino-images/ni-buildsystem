#
# Master makefile
#
# -----------------------------------------------------------------------------

UID := $(shell id -u)
ifeq ($(UID), 0)
warn:
	@echo "You are running as root. Don't do this, it's dangerous."
	@echo "Refusing to build. Good bye."
else

# first target is default ...
default: all

local-files: config.local Makefile.local
	@mkdir -p local/{root,scripts}

# workaround unset variables at first start
config.local: $(eval BOXMODEL=hd51)
	@clear
	@echo ""
	@echo "    ###   ###  ###"
	@echo "     ###   ##  ##"
	@echo "     ####  ##  ##"
	@echo "     ## ## ##  ##"
	@echo "     ##  ####  ##"
	@echo "     ##   ###  ##"
	@echo "     ##    ##  ##      http://www.neutrino-images.de"
	@echo "            #"
	@echo ""
	$(call draw_line);
	@echo ""
	@echo "   1)  Coolstream Nevis (HD1, BSE, Neo, Neo², Zee)"
	@echo "   2)  Coolstream Apollo (Tank)"
	@echo "   3)  Coolstream Shiner (Trinity)"
	@echo "   4)  Coolstream Kronos (Zee², Trinity V2)"
	@echo "   5)  Coolstream Kronos V2 (Link, Trinity Duo)"
	@echo "  11)  AX/Mutant HD51"
	@echo "  21)  WWIO BRE2ZE4K"
	@echo "  31)  VU+ Solo 4k"
	@echo "  32)  VU+ Duo 4k"
	@echo "  33)  VU+ Ultimo 4k"
	@echo "  34)  VU+ Zero 4k"
	@echo "  35)  VU+ Uno 4k"
	@echo "  36)  VU+ Uno 4k SE"
	@echo "  41)  VU+ Duo"
	@echo ""
	@read -p "Select your boxmodel? [default: 11] " boxmodel; \
	boxmodel=$${boxmodel:-11}; \
	case "$$boxmodel" in \
		 1)	boxmodel=nevis;; \
		 2)	boxmodel=apollo;; \
		 3)	boxmodel=shiner;; \
		 4)	boxmodel=kronos;; \
		 5)	boxmodel=kronos_v2;; \
		11)	boxmodel=hd51;; \
		21)	boxmodel=bre2ze4k;; \
		31)	boxmodel=vusolo4k;; \
		32)	boxmodel=vuduo4k;; \
		33)	boxmodel=vuultimo4k;; \
		34)	boxmodel=vuzero4k;; \
		35)	boxmodel=vuuno4k;; \
		36)	boxmodel=vuuno4kse;; \
		41)	boxmodel=vuduo;; \
		*)	boxmodel=hd51;; \
	esac; \
	cp config.example $@; \
	sed -i -e "s|^#BOXMODEL = $$boxmodel|BOXMODEL = $$boxmodel|" $@
	@echo ""

Makefile.local:
	@cp Makefile.example $@

-include config.local
include make/environment-box.mk
include make/environment-linux.mk
include make/environment-build.mk
include make/environment-image.mk
include make/environment-target.mk
include make/environment-update.mk

printenv:
	$(call draw_line);
	@echo "Build Environment Varibles:"
	@echo "CROSS_DIR:   $(CROSS_DIR)"
	@echo "TARGET:      $(TARGET)"
	@echo "BASE_DIR:    $(BASE_DIR)"
	@echo "SOURCE_DIR:  $(SOURCE_DIR)"
	@echo "BUILD:       $(BUILD)"
	@echo "PATH:        `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/             /;'||echo $(PATH)`"
	@echo "BOXARCH:     $(BOXARCH)"
	@echo "BOXTYPE:     $(BOXTYPE)"
	@echo "BOXSERIES:   $(BOXSERIES)"
	@echo "BOXMODEL:    $(BOXMODEL)"
	$(call draw_line);
	@echo ""
	@echo "'make help' lists useful targets."
	@echo ""
	@make --no-print-directory toolcheck
	@make -i -s $(TARGET_DIR)
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if type -p $(TARGET_CC) >/dev/null 2>&1; then \
		echo "$(TARGET_CC) found in PATH or in \$$CROSS_DIR/bin."; \
	else \
		echo "$(TARGET_CC) not found in PATH or \$$CROSS_DIR/bin"; \
		echo "=> please check your setup. Maybe you need to 'make crosstool'."; \
	fi
	@if ! LANG=C make -n preqs|grep -q "Nothing to be done"; then \
		echo; \
		echo "Your next target to do is probably 'make preqs'"; \
	fi
	@if ! test -e $(BASE_DIR)/config.local; then \
		echo; \
		echo "If you want to change the configuration, then run 'make local-files'"; \
		echo "and edit config.local to fit your needs. See the comments in there."; \
		echo; \
	fi

help:
	$(call draw_line);
	@echo "A few helpful make targets:"
	@echo " * make preqs      - Downloads necessary stuff"
	@echo " * make crosstool  - Build cross toolchain"
	@echo " * make bootstrap  - Prepares for building"
	@echo " * make neutrino   - Builds Neutrino"
	@echo " * make image      - Builds our beautiful NI-Image"
	@echo ""
	@echo "Later, you might find those useful:"
	@echo " * make update-all - Update buildsystem and all sources"
	@echo ""
	@echo "Cleanup:"
	@echo " * make clean      - Clean up from previous build an prepare for a new one"
	@echo ""
	@echo "Total renew:"
	@echo " * make all-clean  - Reset buildsystem to delivery state"
	@echo "                     but doesn't touch your local stuff"
	$(call draw_line);

# -----------------------------------------------------------------------------

-include internal/internal.mk

include make/bootstrap.mk
include make/clean.mk
include make/crosstool.mk
include make/helpers.mk
include make/image-updates.mk
include make/images.mk
include make/linux-kernel.mk
include make/linux-drivers.mk
include make/neutrino.mk
include make/neutrino-plugins.mk
include make/prerequisites.mk
include make/target-development.mk
include make/target-ffmpeg$(if $(filter $(BOXTYPE),coolstream),-coolstream).mk
include make/target-gstreamer-unused.mk
include make/target-libs.mk
include make/target-libs-static.mk
include make/target-libs-unused.mk
include make/target-lua.mk
include make/target-rootfs.mk
include make/target-scripts.mk
include make/target-tools.mk
include make/target-tools-unused.mk
include make/host-tools.mk
include make/update.mk

include make/ni.mk

# for your local extensions, e.g. special plugins or similar ...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

all:
	@echo "'make all' is not a valid target. Please read the documentation."

done:
	$(call draw_line);
	@echo -e "$(TERM_GREEN)Done$(TERM_NORMAL)"
	$(call draw_line);

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

.print-phony:
	@echo $(PHONY)

PHONY += local-files
PHONY += printenv help done all everything
PHONY += .print-phony
.PHONY: $(PHONY)

# this makes sure we do not build top-level dependencies in parallel
# (which would not be too helpful anyway, running many configure and
# downloads in parallel...), but the sub-targets are still built in
# parallel, which is useful on multi-processor / multi-core machines
.NOTPARALLEL:
endif
