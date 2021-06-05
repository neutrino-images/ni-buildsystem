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
	$(REMOVE)/$(GNUCONFIG_DIR)
	$(GET_GIT_SOURCE) $(GNUCONFIG_SITE)/$(GNUCONFIG_SOURCE) $(BUILD_DIR)/$(GNUCONFIG_SOURCE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(GNUCONFIG_SOURCE)/config.* support/gnuconfig
	$(REMOVE)/$(GNUCONFIG_DIR)
	@$(call MESSAGE,"Commit your changes in support/gnuconfig")
