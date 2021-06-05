################################################################################
#
# gnuconfig update
#
################################################################################

GNUCONFIG_VERSION = git
GNUCONFIG_DIR = config.$(GNUCONFIG_VERSION)
GNUCONFIG_SOURCE = config.$(GNUCONFIG_VERSION)
GNUCONFIG_SITE = https://git.savannah.gnu.org/git

update-gnuconfig:
ifeq ($(NI_ADMIN),true)
	$(REMOVE)/$(GNUCONFIG_DIR)
	$(GET_GIT_SOURCE) $(GNUCONFIG_SITE)/$(GNUCONFIG_SOURCE) $(BUILD_DIR)/$(GNUCONFIG_DIR)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(GNUCONFIG_DIR)/config.* support/gnuconfig
	$(REMOVE)/$(GNUCONFIG_DIR)
	@$(call MESSAGE,"Commit your changes in support/gnuconfig")
endif
