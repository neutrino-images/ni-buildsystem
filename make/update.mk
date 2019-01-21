#
# makefile for update targets
#
# -----------------------------------------------------------------------------

update-self:
	export GIT_MERGE_AUTOEDIT=no && \
	git pull
ifeq ($(HAS_INTERNALS), yes)
	cd $(BASE_DIR)/$(NI_INTERNALS) && git pull
endif

update-neutrino:
	export GIT_MERGE_AUTOEDIT=no && \
	cd $(SOURCE_DIR)/$(NI_NEUTRINO) && \
		git checkout $(NI_NEUTRINO_BRANCH) && \
		git pull origin $(NI_NEUTRINO_BRANCH) && \
		git fetch

update-remotes:
ifeq ($(NI_ADMIN), true)
	export GIT_MERGE_AUTOEDIT=no && \
	cd $(SOURCE_DIR)/$(NI_NEUTRINO) && \
		git checkout $(NI_NEUTRINO_BRANCH) && \
		git fetch --all
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && \
		git checkout master && \
		git fetch --all && \
		git pull $(TANGO_REMOTE_REPO) master
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && \
		git checkout master && \
		git fetch --all && \
		git pull upstream master
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && \
		git checkout master && \
		git fetch --all && \
		./update-tuxbox-remotes.sh
endif

# rebase of ffmpeg/kernel repos forces us to force push into git repo
# use this target once if such force push was done
update-ni-force:
	#rm -rf $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	rm -rf $(SOURCE_DIR)/$(NI_FFMPEG)
	make ni-sources
	make update-ni-sources

update-ni-sources: ni-sources
	cd $(BUILD-GENERIC-PC) && git pull
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git pull
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git pull --all && git checkout $(NI_FFMPEG_BRANCH)
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git pull --all && git checkout $(NI_LIBCOOLSTREAM_BRANCH)
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git pull
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git pull --all && git checkout $(KERNEL_BRANCH)
	cd $(SOURCE_DIR)/$(NI_LOGO-STUFF) && git pull
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && git pull
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && git pull
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git pull
	cd $(SOURCE_DIR)/$(NI_RTMPDUMP) && git pull
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git pull

update-ni:
	make update-self
	make update-neutrino
	make update-ni-sources

pull \
update-all: update-ni update-remotes

push:
	git push
ifeq ($(HAS_INTERNALS), yes)
	cd $(BASE_DIR)/$(NI_INTERNALS) && git push
endif
	cd $(BUILD-GENERIC-PC) && git push
	cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN) && git push
	cd $(SOURCE_DIR)/$(NI_FFMPEG) && git push --all
ifeq ($(HAS_LIBCS), yes)
	cd $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM) && git push --all
endif
	cd $(SOURCE_DIR)/$(NI_LIBSTB-HAL) && git push
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && git push --all
	cd $(SOURCE_DIR)/$(NI_LOGO-STUFF) && git push
	cd $(SOURCE_DIR)/$(NI_NEUTRINO) && git push
	cd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) && git push
	cd $(SOURCE_DIR)/$(NI_OFGWRITE) && git push
	cd $(SOURCE_DIR)/$(NI_OPENTHREADS) && git push
	cd $(SOURCE_DIR)/$(NI_RTMPDUMP) && git push
	cd $(SOURCE_DIR)/$(NI_STREAMRIPPER) && git push

# -----------------------------------------------------------------------------

PHONY += update-self
PHONY += update-neutrino
PHONY += update-remotes
PHONY += update-ni-force
PHONY += pull
PHONY += update-ni-sources
PHONY += update-ni
PHONY += update-all
PHONY += push
