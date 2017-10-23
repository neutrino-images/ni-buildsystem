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

update-remotes:
ifeq ($(NI_ADMIN), true)
	export GIT_MERGE_AUTOEDIT=no && \
	cd $(N_HD_SOURCE) && \
		git checkout $(NI_NEUTRINO_BRANCH) && \
		git pull $(TUXBOX_REMOTE_REPO) $(TUXBOX_NEUTRINO_BRANCH) && \
		git fetch $(TUXBOX_REMOTE_REPO)
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && \
		git checkout master && \
		git pull $(TUXBOX_REMOTE_REPO) master && \
		git fetch $(TUXBOX_REMOTE_REPO)
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL-NEXT) && \
		git checkout master && \
		git pull $(TANGO_REMOTE_REPO) master && \
		git fetch $(TANGO_REMOTE_REPO)
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && \
		git checkout master && \
		git pull upstream master && \
		git fetch upstream
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && \
		make update-tuxbox-remotes
endif

# rebase of ffmpeg/kernel repos forces us to force push into git repo
# use this target once if such force push was done
update-ni-force:
	#rm -rf $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	rm -rf $(SOURCE_DIR)/$(NI_FFMPEG)
	make ni-git
	make update-ni-git

update-ni-git:
	cd $(BUILD-GENERIC-PC) && git pull
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git pull
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git pull --all && git checkout $(NI_FFMPEG_BRANCH)
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git pull --all && git checkout $(NI_LIBCOOLSTREAM_BRANCH)
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git pull
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL-NEXT) && git pull
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git pull --all && git checkout $(KERNEL_BRANCH)
	cd $(SOURCE_DIR)/$(NI_LOGO-STUFF) && git pull
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && git pull
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && git pull
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git pull
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git pull


update-ni:
	make update-self
	make update-neutrino
	make update-ni-git

update-all: update-ni update-remotes

push:
	git push
ifeq ($(HAS_INTERNALS), yes)
	cd $(BASE_DIR)/$(NI_INTERNALS) && git push
endif
	cd $(N_HD_SOURCE) && git push
	cd $(BUILD-GENERIC-PC) && git push
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git push
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git push
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git push --all
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git push
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL-NEXT) && git push
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git push --all
	cd $(SOURCE_DIR)/$(NI_LOGO-STUFF) && git push
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && git push
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && git push
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git push
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git push

PHONY += update-self update-neutrino
PHONY += update-ni-git update-remotes
PHONY += push
