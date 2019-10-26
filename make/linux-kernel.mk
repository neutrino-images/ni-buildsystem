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
	gfutures/4_10_reserve_dvb_adapter_0.patch \
	gfutures/4_10_t230c2.patch

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
	vuplus/3_9_kernel-add-support-for-gcc-5.patch \
	vuplus/3_9_kernel-add-support-for-gcc6.patch \
	vuplus/3_9_kernel-add-support-for-gcc7.patch \
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

# arm vuduo4k/vuzero4k/vuuno4kse
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

VUSOLO4K_PATCH = \
	$(VUPLUS_3_14_PATCH) \
	vuplus/3_14_linux_rpmb_not_alloc.patch \
	vuplus/3_14_fix_mmc_3.14.28-1.10.patch

VUDUO4K_PATCH = \
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

$(ARCHIVE)/$(KERNEL_SOURCE):
	$(DOWNLOAD) $(KERNEL_URL)/$(KERNEL_SOURCE)

$(ARCHIVE)/$(VMLINUZ-INITRD_SOURCE):
	$(DOWNLOAD) $(VMLINUZ-INITRD_URL)/$(VMLINUZ-INITRD_SOURCE)

# -----------------------------------------------------------------------------

kernel.do_checkout: $(SOURCE_DIR)/$(NI-LINUX-KERNEL)
	$(CD) $(SOURCE_DIR)/$(NI-LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)

kernel.do_prepare:
	$(MAKE) kernel.do_prepare.$(if $(filter $(KERNEL_SOURCE),git),git,tar)
	#
	$(REMOVE)/$(KERNEL_OBJ)
	$(REMOVE)/$(KERNEL_MODULES)
	$(MKDIR)/$(KERNEL_OBJ)
	$(MKDIR)/$(KERNEL_MODULES)
	$(INSTALL_DATA) $(KERNEL_CONFIG) $(BUILD_TMP)/$(KERNEL_OBJ)/.config
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
	$(INSTALL_DATA) $(PATCHES)/initramfs-subdirboot.cpio.gz $(BUILD_TMP)/$(KERNEL_OBJ)
endif
	$(TOUCH)

kernel.do_prepare.git:
	$(MAKE) kernel.do_checkout
	#
	$(REMOVE)/$(KERNEL_TMP)
	tar -C $(SOURCE_DIR) -cp $(NI-LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CD) $(BUILD_TMP); \
		mv $(NI-LINUX-KERNEL) $(KERNEL_TMP)

kernel.do_prepare.tar: $(ARCHIVE)/$(KERNEL_SOURCE)
	$(REMOVE)/$(KERNEL_TMP)
	$(UNTAR)/$(KERNEL_SOURCE)
	$(CHDIR)/$(KERNEL_TMP); \
		$(call apply_patches, $(addprefix kernel/,$(KERNEL_PATCH)))

kernel.do_compile: kernel.do_prepare
	$(CHDIR)/$(KERNEL_TMP); \
		$(MAKE) $(KERNEL_MAKEVARS) silentoldconfig; \
		$(MAKE) $(KERNEL_MAKEVARS) $(KERNEL_MAKEOPTS); \
		$(MAKE) $(KERNEL_MAKEVARS) modules_install
ifneq ($(KERNEL_DTB), $(EMPTY))
	cat $(KERNEL_ZIMAGE) $(KERNEL_DTB) > $(KERNEL_ZIMAGE_DTB)
endif
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel: kernel-$(BOXTYPE) kernel-modules-$(BOXTYPE)
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel-coolstream: kernel-coolstream-$(BOXSERIES)
	$(TOUCH)

kernel-coolstream-hd1: kernel.do_compile | $(IMAGE_DIR)
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(KERNEL_UIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-uImage.img
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img
	$(TOUCH)

kernel-coolstream-hd2: kernel.do_compile | $(IMAGE_DIR)
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE_DTB) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
  ifeq ($(BOXMODEL), apollo)
	# create also shiner-kernel when building apollo
	cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-shiner-vmlinux.ub.gz
  else ifeq ($(BOXMODEL), shiner)
	# create also apollo-kernel when building shiner
	cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-apollo-vmlinux.ub.gz
  endif
endif
	$(TOUCH)

kernel-armbox: kernel.do_compile | $(IMAGE_DIR)
ifneq ($(KERNEL_DTB), $(EMPTY))
	cp -a $(KERNEL_ZIMAGE_DTB) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL).bin
else
	cp -a $(KERNEL_ZIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL).bin
endif
	$(TOUCH)

kernel-mipsbox: kernel.do_compile | $(IMAGE_DIR)
	gzip -9c < $(KERNEL_VMLINUX) > $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL).bin
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel-modules-coolstream: kernel-modules-coolstream-$(BOXSERIES)
	$(TOUCH)

STRIP-MODULES-COOLSTREAM-HD1  =
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/mtd/devices/mtdram.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/mtd/devices/block2mtd.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/net/tun.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/staging/rt2870/rt2870sta.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/ftdi_sio.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/pl2303.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/usbserial.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/autofs4/autofs4.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/cifs/cifs.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/fuse/fuse.ko

kernel-modules-coolstream-hd1: kernel-coolstream
	for module in $(STRIP-MODULES-COOLSTREAM-HD1); do \
		mkdir -p $(TARGET_MODULES_DIR)/$$(dirname $$module); \
		$(TARGET_OBJCOPY) --strip-unneeded $(KERNEL_MODULES_DIR)/$$module $(TARGET_MODULES_DIR)/$$module; \
	done;
	rm -f $(TARGET_MODULES_DIR)/usb-storage.ko # already builtin
	make depmod
	$(TOUCH)

kernel-modules-coolstream-hd2: kernel-coolstream
	cp -a $(KERNEL_MODULES_DIR)/kernel $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod
	make rtl8192eu
	$(TOUCH)

kernel-modules-armbox: kernel-armbox
	cp -a $(KERNEL_MODULES_DIR)/kernel $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod
ifeq ($(BOXSERIES), hd51)
	make rtl8192eu
endif
	$(TOUCH)

kernel-modules-mipsbox: kernel-mipsbox
	cp -a $(KERNEL_MODULES_DIR)/kernel $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod
	$(TOUCH)

# -----------------------------------------------------------------------------

vmlinuz-initrd: $(ARCHIVE)/$(VMLINUZ-INITRD_SOURCE)
	$(UNTAR)/$(VMLINUZ-INITRD_SOURCE)
	$(TOUCH)

# -----------------------------------------------------------------------------

depmod:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VER)
ifeq ($(BOXSERIES), hd1)
	mv $(TARGET_MODULES_DIR)/modules.dep $(TARGET_MODULES_DIR)/.modules.dep
	rm $(TARGET_MODULES_DIR)/modules.*
	mv $(TARGET_MODULES_DIR)/.modules.dep $(TARGET_MODULES_DIR)/modules.dep
endif

# -----------------------------------------------------------------------------

# install coolstream kernels to skel-root

ifneq ($(wildcard $(SKEL-ROOT)-$(BOXFAMILY)),)
  KERNEL_DESTDIR = $(SKEL-ROOT)-$(BOXFAMILY)/var/update
else
  KERNEL_DESTDIR = $(SKEL-ROOT)/var/update
endif

kernel-install-coolstream: kernel-install-coolstream-$(BOXSERIES)

kernel-install-coolstream-hd1: kernel-coolstream-hd1
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img $(KERNEL_DESTDIR)/zImage

kernel-install-coolstream-hd2: kernel-coolstream-hd2
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(KERNEL_DESTDIR)/vmlinux.ub.gz

kernel-install-coolstream-all:
	make clean BOXFAMILY=nevis
	$(MAKE) kernel-coolstream-hd1 BOXFAMILY=nevis
	make kernel-install-coolstream-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=apollo
	make kernel-install-coolstream-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=kronos
	make kernel-install-coolstream-hd2 BOXFAMILY=kronos
	#
	make clean BOXFAMILY=nevis > /dev/null 2>&1
	make get-update-info-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo > /dev/null 2>&1
	make get-update-info-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos > /dev/null 2>&1
	make get-update-info-hd2 BOXFAMILY=kronos
	#
	make clean > /dev/null 2>&1

# -----------------------------------------------------------------------------

PHONY += kernel.do_checkout
