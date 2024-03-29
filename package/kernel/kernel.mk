#
# makefile to build linux-kernel
#
# -----------------------------------------------------------------------------

# arm hd51/bre2ze4k/h7
GFUTURES_4_10_PATCH = \
	gfutures/4_10_0001-export_pmpoweroffprepare.patch \
	gfutures/4_10_0002-TBS-fixes-for-4.10-kernel.patch \
	gfutures/4_10_0003-Support-TBS-USB-drivers-for-4.6-kernel.patch \
	gfutures/4_10_0004-TBS-fixes-for-4.6-kernel.patch \
	gfutures/4_10_0005-STV-Add-PLS-support.patch \
	gfutures/4_10_0006-STV-Add-SNR-Signal-report-parameters.patch \
	gfutures/4_10_0007-blindscan2.patch \
	gfutures/4_10_0007-stv090x-optimized-TS-sync-control.patch \
	gfutures/4_10_add-more-devices-rtl8xxxu.patch \
	gfutures/4_10_bitsperlong.patch \
	gfutures/4_10_blacklist_mmc0.patch \
	gfutures/4_10_dvbs2x.patch \
	gfutures/4_10_reserve_dvb_adapter_0.patch \
	gfutures/4_10_t230c2.patch

# arm hd60/hd61/multibox/multiboxse
GFUTURES_4_4_PATCH = \
	gfutures/0001-remote.patch \
	gfutures/0002-log2-give-up-on-gcc-constant-optimizations.patch \
	gfutures/0003-dont-mark-register-as-const.patch \
	gfutures/0004-linux-fix-buffer-size-warning-error.patch \
	gfutures/0005-xbox-one-tuner-4.4.patch \
	gfutures/0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \
	gfutures/0007-dvb-mn88472-staging.patch \
	gfutures/0008-HauppaugeWinTV-dualHD.patch \
	gfutures/0009-dib7000-linux_4.4.179.patch \
	gfutures/0010-dvb-usb-linux_4.4.179.patch \
	gfutures/0011-wifi-linux_4.4.183.patch \
	gfutures/0012-move-default-dialect-to-SMB3.patch \
	gfutures/0013-modules_mark__inittest__exittest_as__maybe_unused.patch \
	gfutures/0014-includelinuxmodule_h_copy__init__exit_attrs_to_initcleanup_module.patch \
	gfutures/0015-Backport_minimal_compiler_attributes_h_to_support_GCC_9.patch \
	gfutures/0016-mn88472_reset_stream_ID_reg_if_no_PLP_given.patch

# arm vuduo
VUPLUS_3_9_PATCH = \
	vuplus/3_9_0001-rt2800usb-add-support-for-rt55xx.patch \
	vuplus/3_9_0001-stv090x-optimized-TS-sync-control.patch \
	vuplus/3_9_0001-STV-Add-PLS-support.patch \
	vuplus/3_9_0001-STV-Add-SNR-Signal-report-parameters.patch \
	vuplus/3_9_0001-Support-TBS-USB-drivers-3.9.patch \
	vuplus/3_9_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
	vuplus/3_9_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
	vuplus/3_9_add-dmx-source-timecode.patch \
	vuplus/3_9_af9015-output-full-range-SNR.patch \
	vuplus/3_9_af9033-output-full-range-SNR.patch \
	vuplus/3_9_as102-adjust-signal-strength-report.patch \
	vuplus/3_9_as102-scale-MER-to-full-range.patch \
	vuplus/3_9_blindscan2.patch \
	vuplus/3_9_cinergy_s2_usb_r2.patch \
	vuplus/3_9_CONFIG_DVB_SP2.patch \
	vuplus/3_9_cxd2820r-output-full-range-SNR.patch \
	vuplus/3_9_dvbsky-t330.patch \
	vuplus/3_9_dvb-usb-dib0700-disable-sleep.patch \
	vuplus/3_9_dvb_usb_disable_rc_polling.patch \
	vuplus/3_9_fix-dvb-siano-sms-order.patch \
	vuplus/3_9_fix_fuse_for_linux_mips_3-9.patch \
	vuplus/3_9_genksyms_fix_typeof_handling.patch \
	vuplus/3_9_it913x-switch-off-PID-filter-by-default.patch \
	vuplus/3_9_kernel-add-support-for-gcc5.patch \
	vuplus/3_9_kernel-add-support-for-gcc6.patch \
	vuplus/3_9_kernel-add-support-for-gcc7.patch \
	vuplus/3_9_kernel-add-support-for-gcc8.patch \
	vuplus/3_9_kernel-add-support-for-gcc9.patch \
	vuplus/3_9_kernel-add-support-for-gcc10.patch \
	vuplus/3_9_kernel-add-support-for-gcc11.patch \
	vuplus/3_9_kernel-add-support-for-gcc12.patch \
	vuplus/3_9_kernel-add-support-for-gcc13.patch \
	vuplus/3_9_linux-3.9-gcc-4.9.3-build-error-fixed.patch \
	vuplus/3_9_linux-sata_bcm.patch \
	vuplus/3_9_mxl5007t-add-no_probe-and-no_reset-parameters.patch \
	vuplus/3_9_nfs-max-rwsize-8k.patch \
	vuplus/3_9_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
	vuplus/3_9_rtl8187se-fix-warnings.patch \
	vuplus/3_9_rtl8712-fix-warnings.patch \
	vuplus/3_9_tda18271-advertise-supported-delsys.patch \
	vuplus/3_9_test.patch

# arm vusolo4k/vuultimo4k/vuuno4k
VUPLUS_3_14_PATCH = \
	vuplus/3_14_bcm_genet_disable_warn.patch \
	vuplus/3_14_linux_dvb-core.patch \
	vuplus/3_14_dvbs2x.patch \
	vuplus/3_14_dmx_source_dvr.patch \
	vuplus/3_14_rt2800usb_fix_warn_tx_status_timeout_to_dbg.patch \
	vuplus/3_14_usb_core_hub_msleep.patch \
	vuplus/3_14_rtl8712_fix_build_error.patch \
	vuplus/3_14_kernel-add-support-for-gcc6.patch \
	vuplus/3_14_kernel-add-support-for-gcc7.patch \
	vuplus/3_14_kernel-add-support-for-gcc8.patch \
	vuplus/3_14_kernel-add-support-for-gcc9.patch \
	vuplus/3_14_kernel-add-support-for-gcc10.patch \
	vuplus/3_14_kernel-add-support-for-gcc11.patch \
	vuplus/3_14_kernel-add-support-for-gcc12.patch \
	vuplus/3_14_kernel-add-support-for-gcc13.patch \
	vuplus/3_14_fix-linker-issue-undefined-reference.patch \
	vuplus/3_14_0001-Support-TBS-USB-drivers.patch \
	vuplus/3_14_0001-STV-Add-PLS-support.patch \
	vuplus/3_14_0001-STV-Add-SNR-Signal-report-parameters.patch \
	vuplus/3_14_0001-stv090x-optimized-TS-sync-control.patch \
	vuplus/3_14_blindscan2.patch \
	vuplus/3_14_genksyms_fix_typeof_handling.patch \
	vuplus/3_14_0001-tuners-tda18273-silicon-tuner-driver.patch \
	vuplus/3_14_01-10-si2157-Silicon-Labs-Si2157-silicon-tuner-driver.patch \
	vuplus/3_14_02-10-si2168-Silicon-Labs-Si2168-DVB-T-T2-C-demod-driver.patch \
	vuplus/3_14_0003-cxusb-Geniatech-T230-support.patch \
	vuplus/3_14_CONFIG_DVB_SP2.patch \
	vuplus/3_14_dvbsky.patch \
	vuplus/3_14_rtl2832u-2.patch \
	vuplus/3_14_0004-log2-give-up-on-gcc-constant-optimizations.patch \
	vuplus/3_14_0005-uaccess-dont-mark-register-as-const.patch \
	vuplus/3_14_0006-makefile-disable-warnings.patch \
	vuplus/3_14_linux_dvb_adapter.patch

# arm vuduo4k/vuduo4kse/vuzero4k/vuuno4kse
VUPLUS_4_1_PATCH = \
	vuplus/4_1_linux_dvb_adapter.patch \
	vuplus/4_1_linux_dvb-core.patch \
	vuplus/4_1_linux_4_1_45_dvbs2x.patch \
	vuplus/4_1_dmx_source_dvr.patch \
	vuplus/4_1_bcmsysport_4_1_45.patch \
	vuplus/4_1_linux_usb_hub.patch \
	vuplus/4_1_0001-regmap-add-regmap_write_bits.patch \
	vuplus/4_1_0002-af9035-fix-device-order-in-ID-list.patch \
	vuplus/4_1_0003-Add-support-for-dvb-usb-stick-Hauppauge-WinTV-soloHD.patch \
	vuplus/4_1_0004-af9035-add-USB-ID-07ca-0337-AVerMedia-HD-Volar-A867.patch \
	vuplus/4_1_0005-Add-support-for-EVOLVEO-XtraTV-stick.patch \
	vuplus/4_1_0006-dib8000-Add-support-for-Mygica-Geniatech-S2870.patch \
	vuplus/4_1_0007-dib0700-add-USB-ID-for-another-STK8096-PVR-ref-desig.patch \
	vuplus/4_1_0008-add-Hama-Hybrid-DVB-T-Stick-support.patch \
	vuplus/4_1_0009-Add-Terratec-H7-Revision-4-to-DVBSky-driver.patch \
	vuplus/4_1_0010-media-Added-support-for-the-TerraTec-T1-DVB-T-USB-tu.patch \
	vuplus/4_1_0011-media-tda18250-support-for-new-silicon-tuner.patch \
	vuplus/4_1_0012-media-dib0700-add-support-for-Xbox-One-Digital-TV-Tu.patch \
	vuplus/4_1_0013-mn88472-Fix-possible-leak-in-mn88472_init.patch \
	vuplus/4_1_0014-staging-media-Remove-unneeded-parentheses.patch \
	vuplus/4_1_0015-staging-media-mn88472-simplify-NULL-tests.patch \
	vuplus/4_1_0016-mn88472-fix-typo.patch \
	vuplus/4_1_0017-mn88472-finalize-driver.patch \
	vuplus/4_1_0001-dvb-usb-fix-a867.patch \
	vuplus/4_1_kernel-add-support-for-gcc6.patch \
	vuplus/4_1_kernel-add-support-for-gcc7.patch \
	vuplus/4_1_kernel-add-support-for-gcc8.patch \
	vuplus/4_1_kernel-add-support-for-gcc9.patch \
	vuplus/4_1_kernel-add-support-for-gcc10.patch \
	vuplus/4_1_kernel-add-support-for-gcc11.patch \
	vuplus/4_1_kernel-add-support-for-gcc12.patch \
	vuplus/4_1_kernel-add-support-for-gcc13.patch \
	vuplus/4_1_0001-Support-TBS-USB-drivers-for-4.1-kernel.patch \
	vuplus/4_1_0001-TBS-fixes-for-4.1-kernel.patch \
	vuplus/4_1_0001-STV-Add-PLS-support.patch \
	vuplus/4_1_0001-STV-Add-SNR-Signal-report-parameters.patch \
	vuplus/4_1_blindscan2.patch \
	vuplus/4_1_0001-stv090x-optimized-TS-sync-control.patch \
	vuplus/4_1_0002-log2-give-up-on-gcc-constant-optimizations.patch \
	vuplus/4_1_0003-uaccess-dont-mark-register-as-const.patch

# -----------------------------------------------------------------------------

HD51_PATCH = \
	$(GFUTURES_4_10_PATCH)

BRE2ZE4K_PATCH = \
	$(GFUTURES_4_10_PATCH)

H7_PATCH = \
	$(GFUTURES_4_10_PATCH)

E4HDULTRA_PATCH = \
	$(GFUTURES_4_10_PATCH)

PROTEK4K_PATCH = \
	$(GFUTURES_4_10_PATCH)

HD60_PATCH = \
	$(GFUTURES_4_4_PATCH)

HD61_PATCH = \
	$(GFUTURES_4_4_PATCH)

MULTIBOX_PATCH = \
	$(GFUTURES_4_4_PATCH)

MULTIBOXSE_PATCH = \
	$(GFUTURES_4_4_PATCH)

VUSOLO4K_PATCH = \
	$(VUPLUS_3_14_PATCH) \
	vuplus/3_14_linux_rpmb_not_alloc.patch \
	vuplus/3_14_fix_mmc_3.14.28-1.10.patch

VUDUO4K_PATCH = \
	$(VUPLUS_4_1_PATCH)

VUDUO4KSE_PATCH = \
	$(VUPLUS_4_1_PATCH)

VUULTIMO4K_PATCH = \
	$(VUPLUS_3_14_PATCH) \
	vuplus/3_14_bcmsysport_3.14.28-1.12.patch \
	vuplus/3_14_linux_prevent_usb_dma_from_bmem.patch

VUZERO4K_PATCH = \
	$(VUPLUS_4_1_PATCH) \
	vuplus/4_1_bcmgenet-recovery-fix.patch \
	vuplus/4_1_linux_rpmb_not_alloc.patch

VUUNO4K_PATCH = \
	$(VUPLUS_3_14_PATCH) \
	vuplus/3_14_bcmsysport_3.14.28-1.12.patch \
	vuplus/3_14_linux_prevent_usb_dma_from_bmem.patch

VUUNO4KSE_PATCH = \
	$(VUPLUS_4_1_PATCH) \
	vuplus/4_1_bcmgenet-recovery-fix.patch \
	vuplus/4_1_linux_rpmb_not_alloc.patch

VUDUO_PATCH = \
	$(VUPLUS_3_9_PATCH)

# -----------------------------------------------------------------------------

# Older versions break on gcc 10+ because of redefined symbols
define LINUX_FIX_YYLLOC
	$(Q)$(SED) 's/^YYLTYPE yylloc;/extern YYLTYPE yylloc;/' $(BUILD_DIR)/$(KERNEL_DIR)/scripts/dtc/dtc-lexer.lex.c_shipped
endef

# -----------------------------------------------------------------------------

LINUX_KERNEL_MAKE_VARS = \
	$(KERNEL_MAKE_VARS) \
	INSTALL_MOD_PATH=$(KERNEL_MODULES_DIR) \
	INSTALL_HDR_PATH=$(KERNEL_HEADERS_DIR)

kernel.do_checkout: $(SOURCE_DIR)/$(NI_LINUX_KERNEL)
	$(CD) $(SOURCE_DIR)/$(NI_LINUX_KERNEL); \
		git checkout $(KERNEL_BRANCH)

kernel.do_prepare: | $(DEPS_DIR) $(BUILD_DIR)
	$(MAKE) kernel.do_prepare_$(if $(filter $(KERNEL_SOURCE),git),git,tar)
	$(REMOVE)/$(KERNEL_OBJ)
	$(REMOVE)/$(KERNEL_MODULES)
	$(MKDIR)/$(KERNEL_OBJ)
	$(MKDIR)/$(KERNEL_MODULES)
	$(INSTALL_DATA) $(KERNEL_CONFIG) $(KERNEL_OBJ_DIR)/.config
	$(MAKE) -C $(BUILD_DIR)/$(KERNEL_DIR) $(LINUX_KERNEL_MAKE_VARS) silentoldconfig
ifeq ($(IMAGE_LAYOUT),subdirboot)
	$(INSTALL_DATA) $(PKG_FILES_DIR)/initramfs-subdirboot.cpio.gz $(KERNEL_OBJ_DIR)
endif
	$(call TOUCH)

kernel.do_prepare_git:
	$(MAKE) kernel.do_checkout
	#
	$(REMOVE)/$(KERNEL_DIR)
	tar -C $(SOURCE_DIR) --exclude-vcs -cp $(NI_LINUX_KERNEL) | tar -C $(BUILD_DIR) -x
	$(CD) $(BUILD_DIR); \
		mv $(NI_LINUX_KERNEL) $(KERNEL_DIR)

kernel.do_prepare_tar:
	$(call PREPARE)
	$(LINUX_FIX_YYLLOC)

kernel.do_compile: kernel.do_prepare
	$(MAKE) -C $(BUILD_DIR)/$(KERNEL_DIR) $(LINUX_KERNEL_MAKE_VARS) modules $(KERNEL_MAKE_TARGETS)
	$(MAKE) -C $(BUILD_DIR)/$(KERNEL_DIR) $(LINUX_KERNEL_MAKE_VARS) modules_install
ifneq ($(KERNEL_DTB),$(empty))
	cat $(KERNEL_ZIMAGE) $(KERNEL_DTB) > $(KERNEL_ZIMAGE_DTB)
endif
	$(call TOUCH)

# -----------------------------------------------------------------------------

kernel: kernel-$(BOXTYPE) kernel-modules-$(BOXTYPE)
	$(call TOUCH)

# -----------------------------------------------------------------------------

kernel-coolstream: kernel-coolstream-$(BOXSERIES)
	$(call TOUCH)

kernel-coolstream-hd1: kernel.do_compile | $(IMAGE_DIR)
	$(HOST_MKIMAGE_BINARY) -A $(TARGET_ARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE) $(TARGET_localstatedir)/update/zImage
	$(INSTALL_DATA) $(TARGET_localstatedir)/update/zImage $(IMAGE_DIR)/$(IMAGE_NAME)-zImage.img
	$(call TOUCH)

kernel-coolstream-hd2: kernel.do_compile | $(IMAGE_DIR)
	$(HOST_MKIMAGE_BINARY) -A $(TARGET_ARCH) -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE_DTB) $(TARGET_localstatedir)/update/vmlinux.ub.gz
	$(INSTALL_DATA) $(TARGET_localstatedir)/update/vmlinux.ub.gz $(IMAGE_DIR)/$(IMAGE_NAME)-vmlinux.ub.gz
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner))
  ifeq ($(BOXMODEL),apollo)
	# create kernel for shiner too when building apollo
	$(INSTALL_DATA) $(TARGET_localstatedir)/update/vmlinux.ub.gz $(IMAGE_DIR)/$(subst apollo,shiner,$(IMAGE_NAME))-vmlinux.ub.gz
  else ifeq ($(BOXMODEL),shiner)
	# create kernel for apollo too when building shiner
	$(INSTALL_DATA) $(TARGET_localstatedir)/update/vmlinux.ub.gz $(IMAGE_DIR)/$(subst shiner,apollo,$(IMAGE_NAME))-vmlinux.ub.gz
  endif
endif
	$(call TOUCH)

kernel-armbox: kernel.do_compile | $(IMAGE_DIR)
	$(call TOUCH)

kernel-mipsbox: kernel.do_compile | $(IMAGE_DIR)
	gzip -9c < $(KERNEL_VMLINUX) > $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL).bin
	$(call TOUCH)

# -----------------------------------------------------------------------------

kernel-modules-coolstream: kernel-modules-coolstream-$(BOXSERIES)
	$(call TOUCH)

STRIP_MODULES_COOLSTREAM_HD1  =
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/mtd/devices/mtdram.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/mtd/devices/block2mtd.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/net/tun.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/staging/rt2870/rt2870sta.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/usb/serial/ftdi_sio.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/usb/serial/pl2303.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/drivers/usb/serial/usbserial.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/fs/autofs4/autofs4.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/fs/cifs/cifs.ko
STRIP_MODULES_COOLSTREAM_HD1 += kernel/fs/fuse/fuse.ko

kernel-modules-coolstream-hd1: kernel-coolstream
	$(INSTALL) -d $(TARGET_modulesdir)
	for module in $(STRIP_MODULES_COOLSTREAM_HD1); do \
		$(INSTALL) -d $(TARGET_modulesdir)/$$(dirname $$module); \
		$(TARGET_OBJCOPY) --strip-unneeded $(KERNEL_modulesdir)/$$module $(TARGET_modulesdir)/$$module; \
	done;
	rm -f $(TARGET_modulesdir)/usb-storage.ko # already builtin
	$(LINUX_RUN_DEPMOD)
	find $(TARGET_modulesdir) -type f -name 'modules.*' -not -name 'modules.dep' -print0 | xargs -0 rm --
	$(call TOUCH)

kernel-modules-coolstream-hd2: kernel-coolstream
	$(INSTALL) -d $(TARGET_modulesdir)
	$(INSTALL_COPY) $(KERNEL_modulesdir)/kernel $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.builtin $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.order $(TARGET_modulesdir)
	$(LINUX_RUN_DEPMOD)
	$(MAKE) rtl8192eu
	$(call TOUCH)

kernel-modules-armbox: kernel-armbox
	$(INSTALL) -d $(TARGET_modulesdir)
	$(INSTALL_COPY) $(KERNEL_modulesdir)/kernel $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.builtin $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.order $(TARGET_modulesdir)
	$(LINUX_RUN_DEPMOD)
ifeq ($(BOXSERIES),hd5x hd6x)
	$(MAKE) rtl8192eu
	$(MAKE) rtl8812au
	$(MAKE) rtl8822bu
endif
ifeq ($(BOXSERIES),hd6x)
	$(MAKE) hd6x-mali-drivers
endif
	$(call TOUCH)

kernel-modules-mipsbox: kernel-mipsbox
	$(INSTALL) -d $(TARGET_modulesdir)
	$(INSTALL_COPY) $(KERNEL_modulesdir)/kernel $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.builtin $(TARGET_modulesdir)
	$(INSTALL_DATA) $(KERNEL_modulesdir)/modules.order $(TARGET_modulesdir)
	$(LINUX_RUN_DEPMOD)
	$(call TOUCH)

# -----------------------------------------------------------------------------

kernel-headers: $(KERNEL_HEADERS_DIR)
$(KERNEL_HEADERS_DIR): kernel.do_prepare
	$(MAKE) -C $(BUILD_DIR)/$(KERNEL_DIR) $(LINUX_KERNEL_MAKE_VARS) headers_install

kernel-tarball: $(KERNEL_TARBALL)
$(KERNEL_TARBALL): kernel.do_prepare
	tar cf $(@) -C $(BUILD_DIR)/$(KERNEL_DIR) .

# -----------------------------------------------------------------------------

PHONY += kernel.do_checkout
