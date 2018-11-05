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

# workaround unset variables at first start
local-files: $(eval BOXMODEL = nevis)
	@test -e config.local || cp config.example config.local
	@test -e Makefile.local || cp Makefile.example Makefile.local
	@mkdir -p local/{root,scripts}

-include config.local
include make/environment-build.mk
include make/environment-image.mk
include make/environment-target.mk
include make/environment-update.mk
-include internal/internal.mk

printenv:
	@echo '============================================================================== '
	@echo "Build Environment Varibles:"
	@echo "CROSS_DIR:   $(CROSS_DIR)"
	@echo "TARGET:      $(TARGET)"
	@echo "BASE_DIR:    $(BASE_DIR)"
	@echo "BUILD:       $(BUILD)"
	@echo "PATH:        `type -p fmt>/dev/null&&echo $(PATH)|sed 's/:/ /g' |fmt -65|sed 's/ /:/g; 2,$$s/^/             /;'||echo $(PATH)`"
	@echo "N_HD_SOURCE: $(N_HD_SOURCE)"
	@echo "BOXARCH:     $(BOXARCH)"
	@echo "BOXTYPE:     $(BOXTYPE)"
	@echo "BOXSERIES:   $(BOXSERIES)"
	@echo "BOXMODEL:    $(BOXMODEL)"
	@echo '============================================================================== '
	@echo ""
	@echo "'make help' lists useful targets."
	@echo ""
	@make --no-print-directory toolcheck
	@make -i -s $(TARGET_DIR)
	@PATH=$(PATH):$(CROSS_DIR)/bin && \
	if type -p $(TARGET)-gcc >/dev/null 2>&1; then \
		echo "$(TARGET)-gcc found in PATH or in \$$CROSS_DIR/bin."; \
	else \
		echo "$(TARGET)-gcc not found in PATH or \$$CROSS_DIR/bin"; \
		echo "=> please check your setup. Maybe you need to 'make crosstool'."; \
	fi
	@if ! LANG=C make -n preqs|grep -q "Nothing to be done"; then \
		echo; \
		echo "Your next target to do is probably 'make preqs'"; \
	fi
	@if ! test -e $(BASE_DIR)/config.local; then \
		echo; \
		echo "If you want to change the configuration, then run"; \
		echo -e "$(TERM_YELLOW)cp config.example config.local$(TERM_NORMAL)"; \
		echo "and edit config.local to fit your needs. See the comments in there."; \
		echo; \
	fi

help:
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

done:
# -----------------------------------------------------------------------------
	@echo "*************"
	@echo -e "*** $(TERM_GREEN)Done!$(TERM_NORMAL) ***"
	@echo "*************"

include make/archives.mk
include make/bootstrap.mk
include make/clean.mk
include make/crosstool.mk
include make/development-tools.mk
include make/ffmpeg-$(BOXTYPE_SC).mk
include make/gstreamer.mk
include make/host-tools.mk
include make/image-update.mk
include make/images.mk
include make/kernel-$(BOXTYPE_SC).mk
include make/neutrino.mk
include make/plugins-extra.mk
include make/plugins.mk
include make/prerequisites.mk
include make/rootfs.mk
include make/static-libs.mk
include make/system-libs-extra.mk
include make/system-libs.mk
include make/system-scripts.mk
include make/system-tools-extra.mk
include make/system-tools.mk
include make/update.mk

include make/ni.mk

all:
	@echo "'make all' is not a valid target. Please read the documentation."

# target for testing only. not useful otherwise
everything: $(shell sed -n 's/^\$$.D.\/\(.*\):.*/\1/p' make/*.mk)

# for local extensions, e.g. special plugins or similar...
# put them into $(BASE_DIR)/local since that is ignored in .gitignore
-include ./Makefile.local

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
