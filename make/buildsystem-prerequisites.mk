#
# makefile for basic prerequisites
#
# -----------------------------------------------------------------------------

init: preqs crosstool bootstrap

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
		git remote add upstream $(GITHUB)/ffmpeg/ffmpeg.git; \
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
PHONY += preqs
PHONY += ni-sources
