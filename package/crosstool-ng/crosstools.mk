################################################################################
#
# crosstools
#
################################################################################

CROSSTOOLS_BOXSERIES = \
	hd2 \
	hd5x hd6x \
	vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse \
	vuduo

crosstool: build-clean deps-clean crosstool-ng crosstool-backup clean

crosstools:
	$(foreach boxseries,$(CROSSTOOLS_BOXSERIES),\
		make BOXSERIES=$(boxseries) crosstool$(sep))

crosstool.renew: ccache-clean cross-clean crosstool

crosstools.renew:
	$(foreach boxseries,$(CROSSTOOLS_BOXSERIES),\
		make BOXSERIES=$(boxseries) crosstool.renew$(sep))

# -----------------------------------------------------------------------------

CROSSTOOLS_UPGRADECONFIG_BOXTYPES = \
	armbox \
	mipsbox

crosstool.upgradeconfig: build-clean deps-clean crosstool-ng.upgradeconfig

crosstools.upgradeconfig:
	$(foreach boxtype,$(CROSSTOOLS_UPGRADECONFIG_BOXTYPES),\
		make BOXTYPE=$(boxtype) crosstool.upgradeconfig$(sep))

################################################################################
#
# crosstool-backup
#
################################################################################

CROSSTOOL_BACKUP = $(DL_DIR)/crosstool-ng-$(CROSSTOOL_NG_VERSION)-$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)-backup.tar.gz

$(CROSSTOOL_BACKUP):
	@$(call draw_line);
	@echo "CROSSTOOL_BACKUP does not exist. You probably need to run 'make crosstool-backup' first."
	@$(call draw_line);
	@false

crosstool-backup:
	tar czvf $(CROSSTOOL_BACKUP) -C $(CROSS_DIR) .

crosstool-restore: $(CROSSTOOL_BACKUP) cross-clean
	$(INSTALL) -d $(CROSS_DIR)
	tar xzvf $(CROSSTOOL_BACKUP) -C $(CROSS_DIR)
