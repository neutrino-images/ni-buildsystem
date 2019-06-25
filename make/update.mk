#
# makefile for update targets
#
# -----------------------------------------------------------------------------

update-self:
	export GIT_MERGE_AUTOEDIT=no; \
	git pull
ifeq ($(HAS_INTERNALS), yes)
	$(CD) $(BASE_DIR)/$(NI_INTERNALS); git pull
endif

update-neutrino:
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		git checkout $(NI_NEUTRINO_BRANCH); \
		git pull origin $(NI_NEUTRINO_BRANCH)

update-remotes:
ifeq ($(NI_ADMIN), true)
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		git checkout $(NI_NEUTRINO_BRANCH); \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB-HAL); \
		git checkout master; \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); \
		git checkout master; \
		git fetch --all; \
		git pull upstream master
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS); \
		git checkout master; \
		git fetch --all; \
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
	$(CD) $(BUILD-GENERIC-PC); git pull
	$(CD) $(SOURCE_DIR)/$(NI_DRIVERS-BIN); git pull
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git pull --all; git checkout $(NI_FFMPEG_BRANCH)
ifeq ($(HAS_LIBCS), yes)
	$(CD) $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM); git pull --all; git checkout $(NI_LIBCOOLSTREAM_BRANCH)
endif
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB-HAL); git pull
	$(CD) $(SOURCE_DIR)/$(NI_LINUX-KERNEL); git pull --all; git checkout $(KERNEL_BRANCH)
	$(CD) $(SOURCE_DIR)/$(NI_LOGO-STUFF); git pull
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS); git pull
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); git pull
	$(CD) $(SOURCE_DIR)/$(NI_OPENTHREADS); git pull
	$(CD) $(SOURCE_DIR)/$(NI_RTMPDUMP); git pull
	$(CD) $(SOURCE_DIR)/$(NI_STREAMRIPPER); git pull

update-ni:
	make update-self
	make update-neutrino
	make update-ni-sources

pull \
update-all: update-ni update-remotes

push:
	git push
ifeq ($(HAS_INTERNALS), yes)
	$(CD) $(BASE_DIR)/$(NI_INTERNALS); git push
endif
	$(CD) $(BUILD-GENERIC-PC); git push
	$(CD) $(SOURCE_DIR)/$(NI_DRIVERS-BIN); git push
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git push --all
ifeq ($(HAS_LIBCS), yes)
	$(CD) $(SOURCE_DIR)/$(NI_LIBCOOLSTREAM); git push --all
endif
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB-HAL); git push
	$(CD) $(SOURCE_DIR)/$(NI_LINUX-KERNEL); git push --all
	$(CD) $(SOURCE_DIR)/$(NI_LOGO-STUFF); git push
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); git push
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS); git push
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); git push
	$(CD) $(SOURCE_DIR)/$(NI_OPENTHREADS); git push
	$(CD) $(SOURCE_DIR)/$(NI_RTMPDUMP); git push
	$(CD) $(SOURCE_DIR)/$(NI_STREAMRIPPER); git push

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
