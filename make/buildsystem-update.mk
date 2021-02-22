#
# makefile for update targets
#
# -----------------------------------------------------------------------------

update-self:
	export GIT_MERGE_AUTOEDIT=no; \
	git pull
ifeq ($(HAS_INTERNALS),yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git pull
endif

update-neutrino:
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		git checkout master; \
		git pull --all

update-remotes:
ifeq ($(NI_ADMIN),true)
	export GIT_MERGE_AUTOEDIT=no; \
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		git checkout master; \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB_HAL); \
		git checkout master; \
		git fetch --all
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); \
		git checkout master; \
		git fetch --all; \
		git pull upstream master
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS); \
		git checkout master; \
		git fetch --all; \
		./update-tuxbox-remotes.sh
endif

# rebase of ffmpeg/kernel repos forces us to force push into git repo
# use this target once if such force push was done
update-ni-force:
	#rm -rf $(SOURCE_DIR)/$(NI_LINUX_KERNEL)
	rm -rf $(SOURCE_DIR)/$(NI_FFMPEG)
	make ni-sources
	make update-ni-sources

update-ni-sources: ni-sources update-neutrino
	$(CD) $(BUILD_GENERIC_PC); git pull
	$(CD) $(SOURCE_DIR)/$(NI_DRIVERS_BIN); git pull
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git pull --all
ifeq ($(HAS_LIBCS),yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git pull
endif
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB_HAL); git pull
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); git pull --all
	$(CD) $(SOURCE_DIR)/$(NI_LOGO_STUFF); git pull
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS); git pull
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); git pull
	$(CD) $(SOURCE_DIR)/$(NI_OPENTHREADS); git pull
	$(CD) $(SOURCE_DIR)/$(NI_RTMPDUMP); git pull
	$(CD) $(SOURCE_DIR)/$(NI_STREAMRIPPER); git pull
	make checkout-branches

update: update-self update-ni-sources

pull \
update-all: update update-remotes

push:
	git push
ifeq ($(HAS_INTERNALS),yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git push
endif
	$(CD) $(BUILD_GENERIC_PC); git push
	$(CD) $(SOURCE_DIR)/$(NI_DRIVERS_BIN); git push
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git push --all
ifeq ($(HAS_LIBCS),yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git push --all
endif
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB_HAL); git push
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); git push --all
	$(CD) $(SOURCE_DIR)/$(NI_LOGO_STUFF); git push
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); git push
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS); git push
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); git push
	$(CD) $(SOURCE_DIR)/$(NI_OPENTHREADS); git push
	$(CD) $(SOURCE_DIR)/$(NI_RTMPDUMP); git push
	$(CD) $(SOURCE_DIR)/$(NI_STREAMRIPPER); git push

status:
	git status -s -b
ifeq ($(HAS_INTERNALS),yes)
	$(CD) $(BASE_DIR)/$(NI-INTERNALS); git status -s -b
endif
	$(CD) $(BUILD_GENERIC_PC); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_DRIVERS_BIN); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_FFMPEG); git status -s -b
ifeq ($(HAS_LIBCS),yes)
	$(CD) $(SOURCE_DIR)/$(NI-LIBCOOLSTREAM); git status -s -b
endif
	$(CD) $(SOURCE_DIR)/$(NI_LIBSTB_HAL); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_LOGO_STUFF); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_OFGWRITE); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_OPENTHREADS); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_RTMPDUMP); git status -s -b
	$(CD) $(SOURCE_DIR)/$(NI_STREAMRIPPER); git status -s -b

# -----------------------------------------------------------------------------

REPOSITORIES = \
	. \
	$(BUILD_GENERIC_PC) \
	$(SOURCE_DIR)/$(NI_DRIVERS_BIN) \
	$(SOURCE_DIR)/$(NI_FFMPEG) \
	$(SOURCE_DIR)/$(NI_LIBSTB_HAL) \
	$(SOURCE_DIR)/$(NI_LINUX_KERNEL) \
	$(SOURCE_DIR)/$(NI_LOGO_STUFF) \
	$(SOURCE_DIR)/$(NI_NEUTRINO) \
	$(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS) \
	$(SOURCE_DIR)/$(NI_OFGWRITE) \
	$(SOURCE_DIR)/$(NI_OPENTHREADS) \
	$(SOURCE_DIR)/$(NI_RTMPDUMP) \
	$(SOURCE_DIR)/$(NI_STREAMRIPPER)

URL_OLD = $(BITBUCKET_SSH):neutrino-images
URL_NEW = $(if $(filter $(USE_SSH),y),$(GITHUB_SSH):neutrino-images,$(GITHUB)/neutrino-images)

switch-url:
	for repo in $(REPOSITORIES); do \
		$(SED) 's|url = $(URL_OLD)|url = $(URL_NEW)|' $$repo/.git/config; \
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
