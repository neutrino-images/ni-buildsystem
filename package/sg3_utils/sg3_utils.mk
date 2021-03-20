################################################################################
#
# sg3_utils
#
################################################################################

SG3_UTILS_VERSION = 1.45
SG3_UTILS_DIR = sg3_utils-$(SG3_UTILS_VERSION)
SG3_UTILS_SOURCE = sg3_utils-$(SG3_UTILS_VERSION).tar.xz
SG3_UTILS_SITE = http://sg.danny.cz/sg/p

SG3_UTILS_CONF_OPTS = \
	--bindir=$(bindir).$(@F)

SG3_UTILS_BINARIES = sg_start

define SG3_UTILS_INSTALL_BINARIES
	for bin in $(SG3_UTILS_BINARIES); do \
		rm -f $(TARGET_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_bindir).$(@F)/$$bin $(TARGET_bindir)/$$bin; \
	done
	rm -r $(TARGET_bindir).$(@F)
endef
SG3_UTILS_TARGET_FINALIZE_HOOKS += SG3_UTILS_INSTALL_BINARIES

define SG3_UTILS_INSTALL_SDX_INIT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/sdX.init $(TARGET_sysconfdir)/init.d/sdX
	$(UPDATE-RC.D) sdX stop 97 0 6 .
endef
SG3_UTILS_TARGET_FINALIZE_HOOKS += SG3_UTILS_INSTALL_SDX_INIT

sg3_utils: | $(TARGET_DIR)
	$(call autotools-package)
