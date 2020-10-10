#
# makefile for update targets
#
# -----------------------------------------------------------------------------

update-self:
	export GIT_MERGE_AUTOEDIT=no; \
	git pull
ifeq ($(HAS_INTERNALS), yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git pull
endif

update-neutrino:
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); \
		git checkout $(NI-NEUTRINO_BRANCH); \
		git pull origin $(NI-NEUTRINO_BRANCH)

update-remotes:
ifeq ($(NI_ADMIN), true)
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); \
		git checkout $(NI-NEUTRINO_BRANCH); \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI-LIBSTB-HAL); \
		git checkout master; \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI-OFGWRITE); \
		git checkout master; \
		git fetch --all; \
		git pull upstream master
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS); \
		git checkout master; \
		git fetch --all; \
		./update-tuxbox-remotes.sh
endif

# rebase of ffmpeg/kernel repos forces us to force push into git repo
# use this target once if such force push was done
update-ni-force:
	#rm -rf $(SOURCE_DIR)/$(NI-LINUX-KERNEL)
	rm -rf $(SOURCE_DIR)/$(NI-FFMPEG)
	make ni-sources
	make update-ni-sources

update-ni-sources: ni-sources
	$(CD) $(BUILD-GENERIC-PC); git pull
	$(CD) $(SOURCE_DIR)/$(NI-DRIVERS-BIN); git pull
	$(CD) $(SOURCE_DIR)/$(NI-FFMPEG); git pull --all; git checkout $(NI-FFMPEG_BRANCH)
ifeq ($(HAS_LIBCS), yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git pull --all; git checkout $(NI-LIBCOOLSTREAM_BRANCH)
endif
	$(CD) $(SOURCE_DIR)/$(NI-LIBSTB-HAL); git pull
	$(CD) $(SOURCE_DIR)/$(NI-LINUX-KERNEL); git pull --all; git checkout $(KERNEL_BRANCH)
	$(CD) $(SOURCE_DIR)/$(NI-LOGO-STUFF); git pull
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS); git pull
	$(CD) $(SOURCE_DIR)/$(NI-OFGWRITE); git pull
	$(CD) $(SOURCE_DIR)/$(NI-OPENTHREADS); git pull
	$(CD) $(SOURCE_DIR)/$(NI-RTMPDUMP); git pull
	$(CD) $(SOURCE_DIR)/$(NI-STREAMRIPPER); git pull

update-ni:
	make update-self
	make update-neutrino
	make update-ni-sources

pull \
update-all: update-ni update-remotes

push:
	git push
ifeq ($(HAS_INTERNALS), yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git push
endif
	$(CD) $(BUILD-GENERIC-PC); git push
	$(CD) $(SOURCE_DIR)/$(NI-DRIVERS-BIN); git push
	$(CD) $(SOURCE_DIR)/$(NI-FFMPEG); git push --all
ifeq ($(HAS_LIBCS), yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git push --all
endif
	$(CD) $(SOURCE_DIR)/$(NI-LIBSTB-HAL); git push
	$(CD) $(SOURCE_DIR)/$(NI-LINUX-KERNEL); git push --all
	$(CD) $(SOURCE_DIR)/$(NI-LOGO-STUFF); git push
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); git push
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS); git push
	$(CD) $(SOURCE_DIR)/$(NI-OFGWRITE); git push
	$(CD) $(SOURCE_DIR)/$(NI-OPENTHREADS); git push
	$(CD) $(SOURCE_DIR)/$(NI-RTMPDUMP); git push
	$(CD) $(SOURCE_DIR)/$(NI-STREAMRIPPER); git push

status:
	git status -s -b
ifeq ($(HAS_INTERNALS), yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git status -s -b
endif
	$(CD) $(BUILD-GENERIC-PC); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-DRIVERS-BIN); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-FFMPEG); git status -s -b
ifeq ($(HAS_LIBCS), yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git status -s -b
endif
	$(CD) $(SOURCE_DIR)/$(NI-LIBSTB-HAL); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-LINUX-KERNEL); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-LOGO-STUFF); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-OFGWRITE); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-OPENTHREADS); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-RTMPDUMP); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI-STREAMRIPPER); git status -s -b

# -----------------------------------------------------------------------------

REPOSITORIES = \
	. \
	$(BUILD-GENERIC-PC) \
	$(SOURCE_DIR)/$(NI-DRIVERS-BIN) \
	$(SOURCE_DIR)/$(NI-FFMPEG) \
	$(SOURCE_DIR)/$(NI-LIBSTB-HAL) \
	$(SOURCE_DIR)/$(NI-LINUX-KERNEL) \
	$(SOURCE_DIR)/$(NI-LOGO-STUFF) \
	$(SOURCE_DIR)/$(NI-NEUTRINO) \
	$(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS) \
	$(SOURCE_DIR)/$(NI-OFGWRITE) \
	$(SOURCE_DIR)/$(NI-OPENTHREADS) \
	$(SOURCE_DIR)/$(NI-RTMPDUMP) \
	$(SOURCE_DIR)/$(NI-STREAMRIPPER)

URL_OLD = $(BITBUCKET_SSH):neutrino-images
URL_NEW = $(if $(filter $(USE_SSH),y),$(GITHUB_SSH):neutrino-images,$(GITHUB)/neutrino-images)

switch-url:
	for repo in $(REPOSITORIES); do \
		sed -i -e 's|url = $(URL_OLD)|url = $(URL_NEW)|' $$repo/.git/config; \
	done

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
PHONY += status
