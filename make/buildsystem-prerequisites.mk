#
# makefile for basic prerequisites
#
# -----------------------------------------------------------------------------

init: preqs crosstool bootstrap

# -----------------------------------------------------------------------------

TOOLCHECK  =
TOOLCHECK += find-git
TOOLCHECK += find-svn
TOOLCHECK += find-hg
TOOLCHECK += find-curl
TOOLCHECK += find-tar
TOOLCHECK += find-lzma
TOOLCHECK += find-gtkdocize
TOOLCHECK += find-gperf
TOOLCHECK += find-bison
TOOLCHECK += find-help2man
TOOLCHECK += find-makeinfo
TOOLCHECK += find-flex
TOOLCHECK += find-gettextize
TOOLCHECK += find-patch
TOOLCHECK += find-grep
TOOLCHECK += find-gawk
TOOLCHECK += find-sed
TOOLCHECK += find-gcc
TOOLCHECK += find-ccache
TOOLCHECK += find-automake
TOOLCHECK += find-autopoint
TOOLCHECK += find-libtool
TOOLCHECK += find-pkg-config
TOOLCHECK += find-tic

find-%:
	@TOOL=$(patsubst find-%,%,$(@)); which $$TOOL $(if $(VERBOSE),,>/dev/null) || \
		{ $(call WARNING,"Warning",": required tool $$TOOL missing."); false; }

bashcheck:
	@test "$(findstring /bash,$(shell readlink -f /bin/sh))" == "/bash" || \
		{ $(call WARNING,"Warning",": /bin/sh is not linked to bash"); false; }

toolcheck: bashcheck $(TOOLCHECK)
	@$(call SUCCESS,"toolcheck",": All required tools seem to be installed.")

# -----------------------------------------------------------------------------

CROSSCHECK  =
CROSSCHECK += $(TARGET_CC)
CROSSCHECK += $(TARGET_CPP)
CROSSCHECK += $(TARGET_CXX)

crosscheck:
	@for c in $(CROSSCHECK); do \
		if test -e $$c; then \
			$(call SUCCESS,"$$c",": found."); \
		elif test -e $(CROSS_DIR)/bin/$$c; then \
			$(call SUCCESS,"$$c",": found in \$$(CROSS_DIR)/bin"); \
		elif PATH=$(PATH) type -p $$c >/dev/null 2>&1; then \
			$(call SUCCESS,"$$c",": found PATH"); \
		else \
			$(call WARNING,"$$c",": not found in \$$(CROSS_DIR)/bin or PATH"); \
			$(call WARNING,"=> please check your setup. Maybe you need to 'make crosstool'."); \
		fi; \
	done

# -----------------------------------------------------------------------------

preqs: download ni-sources checkout-branches

$(CCACHE):
	@$(call draw_line);
	@echo "ccache package on host missing."
	@$(call draw_line);
	@false

download:
	@$(call draw_line);
	@echo "Download directory missing."
	@echo
	@echo "You need to make a directory named 'download' by executing 'mkdir download' or create a symlink to the directory where you keep your sources, e.g. by typing 'ln -s /path/to/my/Archive download'."
	@$(call draw_line);
	@false

# -----------------------------------------------------------------------------

$(SOURCE_DIR):
	$(INSTALL) -d $(@)

$(GENERIC_PC):
	git clone $(NI_GITHUB)/$(NI_BUILDSYSTEM_GENERIC_PC).git $(GENERIC_PC)

$(SOURCE_DIR)/$(NI_NEUTRINO):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git
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
		git clone $(NI_GITHUB)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add tuxbox $(GITHUB)/tuxbox-neutrino/library-stb-hal.git; \
		git remote add seife  $(GITHUB)/neutrino-mp/libstb-hal.git; \
		git remote add ddt    $(GITHUB)/duckbox-developers/libstb-hal-ddt.git; \
		git remote add tango  $(GITHUB)/tangocash/libstb-hal-tangos.git; \
		git fetch --all
endif

$(SOURCE_DIR)/$(NI_LIBCOOLSTREAM):
ifeq ($(HAS_LIBCOOLSTREAM),yes)
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB_WITH_TOKEN)/$(@F).git
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_FFMPEG):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream https://git.ffmpeg.org/ffmpeg.git; \
		git fetch --all
endif

# upstream for rebase
# torvalds for cherry-picking
$(SOURCE_DIR)/$(NI_LINUX_KERNEL):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git; \
		git remote add torvalds https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git; \
		git fetch --all
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_OFGWRITE):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream $(GITHUB)/oe-alliance/ofgwrite.git; \
		git fetch --all
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_RTMPDUMP):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git
ifeq ($(NI_ADMIN),true)
	$(CD) $(@); \
		git remote add upstream https://git.ffmpeg.org/rtmpdump; \
		git fetch --all
endif

$(SOURCE_DIR)/$(NI_DRIVERS_BIN) \
$(SOURCE_DIR)/$(NI_LOGO_STUFF) \
$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS) \
$(SOURCE_DIR)/$(NI_OPENTHREADS) \
$(SOURCE_DIR)/$(NI_STREAMRIPPER):
	$(CD) $(SOURCE_DIR); \
		git clone $(NI_GITHUB)/$(@F).git

ni-sources: $(SOURCE_DIR) \
	$(GENERIC_PC) \
	$(SOURCE_DIR)/$(NI_DRIVERS_BIN) \
	$(SOURCE_DIR)/$(NI_FFMPEG) \
	$(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) \
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
ifneq ($(BS_PACKAGE_FFMPEG2_BRANCH),$(empty))
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git checkout $(BS_PACKAGE_FFMPEG2_BRANCH)
endif
ifneq ($(KERNEL_BRANCH),$(empty))
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); git checkout $(KERNEL_BRANCH)
endif
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); git checkout $(BS_PACKAGE_NEUTRINO_BRANCH)

# -----------------------------------------------------------------------------

PHONY += init
PHONY += find-%
PHONY += toolcheck
PHONY += bashcheck
PHONY += preqs
PHONY += ni-sources
