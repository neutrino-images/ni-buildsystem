#
# makefile for basic prerequisites
#
# -----------------------------------------------------------------------------

init: preqs crosstool bootstrap

# -----------------------------------------------------------------------------

TOOLCHECK  =
TOOLCHECK += find-automake
TOOLCHECK += find-autopoint
TOOLCHECK += find-bc
TOOLCHECK += find-bison
TOOLCHECK += find-bzip2
TOOLCHECK += find-ccache
TOOLCHECK += find-cmake
TOOLCHECK += find-curl
TOOLCHECK += find-flex
TOOLCHECK += find-gawk
TOOLCHECK += find-gcc
TOOLCHECK += find-gettext
TOOLCHECK += find-git
TOOLCHECK += find-gperf
TOOLCHECK += find-gzip
TOOLCHECK += find-help2man
TOOLCHECK += find-libtool
TOOLCHECK += find-lzma
TOOLCHECK += find-makeinfo
TOOLCHECK += find-patch
TOOLCHECK += find-pkg-config
TOOLCHECK += find-python
TOOLCHECK += find-svn
TOOLCHECK += find-tic
TOOLCHECK += find-yacc

find-%:
	@TOOL=$(patsubst find-%,%,$(@)); \
	type -p $$TOOL >/dev/null || { echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
	@echo "All required tools seem to be installed."
	@make bashcheck

bashcheck:
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != "bash"; then \
		@$(call MESSAGE_RED,"Warning",": /bin/sh is not linked to bash"); \
	fi

# -----------------------------------------------------------------------------

preqs: download ni-sources checkout-branches

$(CCACHE):
	$(call draw_line);
	@echo "ccache package on host missing."
	$(call draw_line);
	@false

download:
	$(call draw_line);
	@echo "Download directory missing."
	@echo
	@echo "You need to make a directory named 'download' by executing 'mkdir download' or create a symlink to the directory where you keep your sources, e.g. by typing 'ln -s /path/to/my/Archive download'."
	$(call draw_line);
	@false

# -----------------------------------------------------------------------------

$(SOURCE_DIR):
	mkdir -p $(@)

$(BUILD_GENERIC_PC):
	git clone $(NI_PUBLIC)/$(NI_BUILD_GENERIC_PC).git $(BUILD_GENERIC_PC)

$(SOURCE_DIR)/$(NI_NEUTRINO):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add tuxbox $(GITHUB)/tuxbox-neutrino/gui-neutrino.git; \
		git remote add seife  $(GITHUB)/neutrino-mp/neutrino-mp.git; \
		git remote add ddt    $(GITHUB)/duckbox-developers/neutrino-ddt.git; \
		git remote add tango  $(GITHUB)/tangocash/neutrino-tangos.git; \
		git fetch --all
endif

$(SOURCE_DIR)/$(NI_LIBSTB_HAL):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add tuxbox $(GITHUB)/tuxbox-neutrino/library-stb-hal.git; \
		git remote add seife  $(GITHUB)/neutrino-mp/libstb-hal.git; \
		git remote add ddt    $(GITHUB)/duckbox-developers/libstb-hal-ddt.git; \
		git remote add tango  $(GITHUB)/tangocash/libstb-hal-tangos.git; \
		git fetch --all
endif

$(SOURCE_DIR)/$(NI-LIBCOOLSTREAM):
ifeq ($(HAS_LIBCOOLSTREAM),yes)
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PRIVATE)/$(@F).git
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_FFMPEG):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream https://git.ffmpeg.org/ffmpeg.git; \
		git fetch --all
endif

# upstream for rebase
# torvalds for cherry-picking
$(SOURCE_DIR)/$(NI_LINUX_KERNEL):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git; \
		git remote add torvalds https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git; \
		git fetch --all
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_OFGWRITE):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream $(GITHUB)/oe-alliance/ofgwrite.git; \
		git fetch --all
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_RTMPDUMP):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream git://git.ffmpeg.org/rtmpdump; \
		git fetch --all
endif

$(SOURCE_DIR)/$(NI_DRIVERS_BIN) \
$(SOURCE_DIR)/$(NI_LOGO_STUFF) \
$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS) \
$(SOURCE_DIR)/$(NI_OPENTHREADS) \
$(SOURCE_DIR)/$(NI_STREAMRIPPER):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_PUBLIC)/$(@F).git

ni-sources: $(SOURCE_DIR) \
	$(BUILD_GENERIC_PC) \
	$(SOURCE_DIR)/$(NI_DRIVERS_BIN) \
	$(SOURCE_DIR)/$(NI_FFMPEG) \
	$(SOURCE_DIR)/$(NI-LIBCOOLSTREAM) \
	$(SOURCE_DIR)/$(NI_LIBSTB_HAL) \
	$(SOURCE_DIR)/$(NI_LINUX_KERNEL) \
	$(SOURCE_DIR)/$(NI_LOGO_STUFF) \
	$(SOURCE_DIR)/$(NI_NEUTRINO) \
	$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS) \
	$(SOURCE_DIR)/$(NI_OFGWRITE) \
	$(SOURCE_DIR)/$(NI_OPENTHREADS) \
	$(SOURCE_DIR)/$(NI_RTMPDUMP) \
	$(SOURCE_DIR)/$(NI_STREAMRIPPER)

checkout-branches:
ifneq ($(FFMPEG_BRANCH),$(empty))
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git checkout $(FFMPEG_BRANCH)
endif
ifneq ($(KERNEL_BRANCH),$(empty))
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); git checkout $(KERNEL_BRANCH)
endif
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); git checkout $(NEUTRINO_BRANCH)

# -----------------------------------------------------------------------------

PHONY += init
PHONY += find-%
PHONY += toolcheck
PHONY += bashcheck
PHONY += preqs
PHONY += ni-sources
