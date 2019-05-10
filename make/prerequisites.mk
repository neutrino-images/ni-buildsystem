#
# makefile for basic prerequisites
#
# -----------------------------------------------------------------------------

init: preqs crosstools bootstrap

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
	@TOOL=$(patsubst find-%,%,$@); \
	type -p $$TOOL >/dev/null || { echo "required tool $$TOOL missing."; false; }

toolcheck: $(TOOLCHECK)
	@echo "All required tools seem to be installed."
	@make bashcheck

bashcheck:
	@if test "$(subst /bin/,,$(shell readlink /bin/sh))" != "bash"; then \
		echo -e "$(TERM_YELLOW)WARNING$(TERM_NORMAL): /bin/sh is not linked to bash."; \
	fi

# -----------------------------------------------------------------------------

preqs: download ni-sources

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
	mkdir -p $@

$(SOURCE_DIR)/$(NI_NEUTRINO):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	pushd $@ && \
		git remote add $(TUXBOX_REMOTE_REPO) $(TUXBOX_GIT)/$(TUXBOX_NEUTRINO).git && \
		git fetch $(TUXBOX_REMOTE_REPO)

$(BUILD-GENERIC-PC):
	git clone $(NI_GIT)/$(NI_BUILD-GENERIC-PC).git $(BUILD-GENERIC-PC)

$(SOURCE_DIR)/$(NI_LIBSTB-HAL):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	cd $@ && \
		git remote add $(TANGO_REMOTE_REPO) https://github.com/TangoCash/libstb-hal-tangos.git && \
		git fetch $(TANGO_REMOTE_REPO)

$(SOURCE_DIR)/$(NI_LIBCOOLSTREAM):
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	cd $@ && \
		git checkout $(NI_LIBCOOLSTREAM_BRANCH)
endif

# upstream for rebase
$(SOURCE_DIR)/$(NI_FFMPEG):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	cd $@ && \
		git remote add upstream https://git.ffmpeg.org/ffmpeg.git && \
		git fetch --all

# upstream for rebase
# torvalds for cherry-picking
$(SOURCE_DIR)/$(NI_LINUX-KERNEL):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	cd $@ && \
		git remote add upstream https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git && \
		git remote add torvalds https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git && \
		git fetch --all

# upstream for rebase
$(SOURCE_DIR)/$(NI_OFGWRITE):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git
	cd $@ && \
		git remote add upstream https://github.com/oe-alliance/ofgwrite.git && \
		git fetch --all

$(SOURCE_DIR)/$(NI_DRIVERS-BIN) \
$(SOURCE_DIR)/$(NI_LOGO-STUFF) \
$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) \
$(SOURCE_DIR)/$(NI_OPENTHREADS) \
$(SOURCE_DIR)/$(NI_RTMPDUMP) \
$(SOURCE_DIR)/$(NI_STREAMRIPPER):
	cd $(SOURCE_DIR) && \
		git clone $(NI_GIT)/$(notdir $@).git

ni-sources: $(SOURCE_DIR) \
	$(BUILD-GENERIC-PC) \
	$(SOURCE_DIR)/$(NI_DRIVERS-BIN) \
	$(SOURCE_DIR)/$(NI_FFMPEG) \
	$(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) \
	$(SOURCE_DIR)/$(NI_LIBSTB-HAL) \
	$(SOURCE_DIR)/$(NI_LINUX-KERNEL) \
	$(SOURCE_DIR)/$(NI_LOGO-STUFF) \
	$(SOURCE_DIR)/$(NI_NEUTRINO) \
	$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) \
	$(SOURCE_DIR)/$(NI_OFGWRITE) \
	$(SOURCE_DIR)/$(NI_OPENTHREADS) \
	$(SOURCE_DIR)/$(NI_RTMPDUMP) \
	$(SOURCE_DIR)/$(NI_STREAMRIPPER)

# -----------------------------------------------------------------------------

archives-list:
	@rm -f $(BUILD_TMP)/$@
	@make -qp | grep --only-matching '^\$(ARCHIVE).*:' | sed "s|:||g" > $(BUILD_TMP)/$@

DOCLEANUP=no
GETMISSING=no
archives-info: archives-list
	@echo "[ ** ] Unused targets in make/archives.mk"
	@grep --only-matching '^\$$(ARCHIVE).*:' make/archives.mk | sed "s|:||g" | \
	while read target; do \
		found=false; \
		for makefile in make/*.mk; do \
			if [ "$${makefile##*/}" = "archives.mk" ]; then \
				continue; \
			fi; \
			if [ "$${makefile: -9}" = "-extra.mk" ]; then \
				continue; \
			fi; \
			if grep -q "$$target" $$makefile; then \
				found=true; \
			fi; \
			if [ "$$found" = "true" ]; then \
				continue; \
			fi; \
		done; \
		if [ "$$found" = "false" ]; then \
			echo -e "[$(TERM_RED) !! $(TERM_NORMAL)] $$target"; \
		fi; \
	done;
	@echo "[ ** ] Unused archives"
	@find $(ARCHIVE)/ -maxdepth 1 -type f | \
	while read archive; do \
		if ! grep -q $$archive $(BUILD_TMP)/archives-list; then \
			echo -e "[$(TERM_YELLOW) rm $(TERM_NORMAL)] $$archive"; \
			if [ "$(DOCLEANUP)" = "yes" ]; then \
				rm $$archive; \
			fi; \
		fi; \
	done;
	@echo "[ ** ] Missing archives"
	@cat $(BUILD_TMP)/archives-list | \
	while read archive; do \
		if [ -e $$archive ]; then \
			#echo -e "[$(TERM_GREEN) ok $(TERM_NORMAL)] $$archive"; \
			true; \
		else \
			echo -e "[$(TERM_YELLOW) -- $(TERM_NORMAL)] $$archive"; \
			if [ "$(GETMISSING)" = "yes" ]; then \
				make $$archive; \
			fi; \
		fi; \
	done;
	@$(REMOVE)/archives-list

# FIXME - how to resolve variables while grepping makefiles?
patches-info:
	@echo "[ ** ] Unused patches"
	@for patch in $(PATCHES)/*; do \
		if [ ! -f $$patch ]; then \
			continue; \
		fi; \
		patch=$${patch##*/}; \
		found=false; \
		for makefile in make/*.mk; do \
			if grep -q "$$patch" $$makefile; then \
				found=true; \
			fi; \
			if [ "$$found" = "true" ]; then \
				continue; \
			fi; \
		done; \
		if [ "$$found" = "false" ]; then \
			echo -e "[$(TERM_RED) !! $(TERM_NORMAL)] $$patch"; \
		fi; \
	done;

# -----------------------------------------------------------------------------

PHONY += init
PHONY += find-%
PHONY += toolcheck
PHONY += bashcheck
PHONY += preqs
PHONY += ni-sources
PHONY += archives-list
PHONY += archives-info
PHONY += patches-info
