# helper targets

update-self:
	export GIT_MERGE_AUTOEDIT=no && \
	git pull
ifeq ($(HAS_INTERNALS), yes)
	cd $(BASE_DIR)/$(NI_INTERNALS) && git pull
endif

update-neutrino:
	export GIT_MERGE_AUTOEDIT=no && \
	cd $(N_HD_SOURCE) && \
		git checkout $(NI_NEUTRINO_BRANCH) && \
		git pull origin $(NI_NEUTRINO_BRANCH) && \
		git fetch

update-$(TUXBOX_REMOTE_REPO):
ifneq ($(NO_REMOTE_REPO), true)
	export GIT_MERGE_AUTOEDIT=no && \
	cd $(N_HD_SOURCE) && \
		git checkout $(NI_NEUTRINO_BRANCH) && \
		git pull $(TUXBOX_REMOTE_REPO) $(TUXBOX_NEUTRINO_BRANCH) && \
		git fetch $(TUXBOX_REMOTE_REPO); \
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && \
		git checkout master && \
		git pull $(TUXBOX_REMOTE_REPO) master && \
		git fetch $(TUXBOX_REMOTE_REPO); \
	cd $(SOURCE_DIR)/$(NI_TUXWETTER) && \
		git checkout master && \
		git pull $(TUXBOX_REMOTE_REPO) master && \
		git fetch $(TUXBOX_REMOTE_REPO)
endif

update-tuxbox-git:
	cd $(SOURCE_DIR)/$(TUXBOX_BOOTLOADER) && git pull
	cd $(SOURCE_DIR)/$(TUXBOX_PLUGINS) && \
		git pull && \
		git submodule foreach 'git checkout master; git pull origin master' && \
		git submodule update

# rebase of ffmpeg/kernel repos forces us to force push into git repo
# use this target once if such force push was done
update-ni-force:
	#rm -rf $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	rm -rf $(SOURCE_DIR)/$(NI_FFMPEG)
	make ni-git
	make update-ni-git

update-ni-git:
	cd $(BUILD-GENERIC-PC) && git pull
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git pull --all && git checkout $(KBRANCH)
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git pull
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git pull --all && git checkout $(NI_LIBCOOLSTREAM_BRANCH)
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git pull
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git pull --all && git checkout $(NI_FFMPEG_BRANCH)
	cd $(SOURCE_DIR)/$(NI_TUXWETTER) && git checkout master && git pull origin master
	cd $(SOURCE_DIR)/$(NI_LOGO_STUFF) && git pull
	cd $(SOURCE_DIR)/$(NI_SMARTHOMEINFO) && git pull
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git pull
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git pull

ni-update:
	make update-self
	make update-neutrino
	make update-ni-git

tuxbox-update:
	make update-$(TUXBOX_REMOTE_REPO)
	make update-tuxbox-git

update-all: ni-update tuxbox-update

push:
	git push
ifeq ($(HAS_INTERNALS), yes)
	cd $(BASE_DIR)/$(NI_INTERNALS) && git push
endif
	cd $(N_HD_SOURCE) && git push
	cd $(BUILD-GENERIC-PC) && git push
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git push --all
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git push
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git push --all
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git push
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git push
	cd $(SOURCE_DIR)/$(NI_TUXWETTER) && git push
	cd $(SOURCE_DIR)/$(NI_LOGO_STUFF) && git push
	cd $(SOURCE_DIR)/$(NI_SMARTHOMEINFO) && git push
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git push
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git push
