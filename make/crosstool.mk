#
# makefile to build crosstools
#
# -----------------------------------------------------------------------------

crosstool: crosstool-$(BOXARCH)-$(BOXSERIES)

crosstools:
	for boxseries in hd1 hd2 hd51; do \
		make BOXSERIES=$${boxseries} crosstool-$(BOXARCH)-$${boxseries} || exit; \
	done;

# -----------------------------------------------------------------------------

CROSSTOOL_BACKUP = $(ARCHIVE)/crosstool-$(BOXARCH)-$(BOXSERIES)-backup.tar.gz

$(CROSSTOOL_BACKUP):
	$(call draw_line);
	@echo "CROSSTOOL_BACKUP does not exist. You probably need to run 'make crosstool-backup' first."
	$(call draw_line);
	@false

crosstool-backup:
	cd $(CROSS_DIR); \
		tar -czvf $(CROSSTOOL_BACKUP) *

crosstool-restore: $(CROSSTOOL_BACKUP)
	make cross-clean
	mkdir -p $(CROSS_DIR)
	tar -xzvf $(CROSSTOOL_BACKUP) -C $(CROSS_DIR)

# -----------------------------------------------------------------------------

crosstools-renew:
	for boxseries in hd1 hd2 hd51; do \
		make BOXSERIES=$${boxseries} ccache-clean static-clean cross-clean || exit; \
	done;
	make host-clean
	make crosstools
	make clean

# -----------------------------------------------------------------------------

crosstool-arm-hd1: CROSS_DIR-check $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng
	git clone https://github.com/crosstool-ng/crosstool-ng $(BUILD_TMP)/crosstool-ng && \
	$(CHDIR)/crosstool-ng && \
		git checkout 1dbb06f2 && \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
		$(MKDIR)/crosstool-ng/targets/src/ && \
			pushd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
				git checkout $(KERNEL_BRANCH) && \
			popd && \
		tar cf linux-$(KERNEL_VERSION).tar --exclude-vcs -C $(SOURCE_DIR)/$(NI_LINUX-KERNEL) . && \
		mv linux-$(KERNEL_VERSION).tar $(BUILD_TMP)/crosstool-ng/targets/src/ && \
		cp -a $(CONFIGS)/ct-ng-$(BOXTYPE)-$(BOXSERIES).config .config && \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$(PARALLEL_JOBS)@" .config && \
		export NI_BASE_DIR=$(BASE_DIR) && \
		export NI_CUSTOM_KERNEL=$(BUILD_TMP)/crosstool-ng/targets/src/linux-$(KERNEL_VERSION).tar && \
		export NI_CUSTOM_KERNEL_VERSION=$(KERNEL_VERSION) && \
		export LD_LIBRARY_PATH= && \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng && \
		./ct-ng oldconfig && \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

UCLIBC_VER=1.0.24
crosstool-arm-hd2: CROSS_DIR-check $(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz $(SOURCE_DIR)/$(NI_LINUX-KERNEL)
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng
	git clone https://github.com/crosstool-ng/crosstool-ng $(BUILD_TMP)/crosstool-ng && \
	$(CHDIR)/crosstool-ng && \
		git checkout 1dbb06f2 && \
		cp -a $(PATCHES)/crosstool-ng/gcc/* $(BUILD_TMP)/crosstool-ng/patches/gcc/linaro-6.3-2017.02 && \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
		$(MKDIR)/crosstool-ng/targets/src/ && \
			pushd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
				git checkout $(KERNEL_BRANCH) && \
			popd && \
		tar cf linux-$(KERNEL_VERSION).tar --exclude-vcs -C $(SOURCE_DIR)/$(NI_LINUX-KERNEL) . && \
		mv linux-$(KERNEL_VERSION).tar $(BUILD_TMP)/crosstool-ng/targets/src/ && \
		cp -a $(CONFIGS)/ct-ng-$(BOXTYPE)-$(BOXSERIES).config .config && \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$(PARALLEL_JOBS)@" .config && \
		export NI_BASE_DIR=$(BASE_DIR) && \
		export NI_CUSTOM_KERNEL=$(BUILD_TMP)/crosstool-ng/targets/src/linux-$(KERNEL_VERSION).tar && \
		export NI_CUSTOM_KERNEL_VERSION=$(KERNEL_VERSION) && \
		export NI_UCLIBC_CONFIG=$(CONFIGS)/ct-ng-uClibc-$(UCLIBC_VER).config && \
		export LD_LIBRARY_PATH= && \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng && \
		./ct-ng oldconfig && \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib && mv $(CROSS_DIR)/$(TARGET)/lib $(CROSS_DIR)/$(TARGET)/lib.x
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.22-gdb.py
	$(REMOVE)/crosstool-ng

crosstool-arm-hd51: CROSS_DIR-check
	make $(BUILD_TMP)
	$(REMOVE)/crosstool-ng
	git clone https://github.com/crosstool-ng/crosstool-ng $(BUILD_TMP)/crosstool-ng && \
	$(CHDIR)/crosstool-ng && \
		git checkout 1dbb06f2 && \
		cp -a $(PATCHES)/crosstool-ng/gcc/* $(BUILD_TMP)/crosstool-ng/patches/gcc/linaro-6.3-2017.02 && \
		unset CONFIG_SITE LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
		$(MKDIR)/crosstool-ng/targets/src/ && \
			pushd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
				git checkout $(KERNEL_BRANCH) && \
			popd && \
		tar cf linux-$(KERNEL_VERSION).tar --exclude-vcs -C $(SOURCE_DIR)/$(NI_LINUX-KERNEL) . && \
		mv linux-$(KERNEL_VERSION).tar $(BUILD_TMP)/crosstool-ng/targets/src/ && \
		cp -a $(CONFIGS)/ct-ng-$(BOXTYPE)-$(BOXSERIES).config .config && \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$(PARALLEL_JOBS)@" .config && \
		export NI_BASE_DIR=$(BASE_DIR) && \
		export NI_CUSTOM_KERNEL=$(BUILD_TMP)/crosstool-ng/targets/src/linux-$(KERNEL_VERSION).tar && \
		export NI_CUSTOM_KERNEL_VERSION=$(KERNEL_VERSION) && \
		export LD_LIBRARY_PATH= && \
		test -f ./configure || ./bootstrap && \
		./configure --enable-local; MAKELEVEL=0 make; chmod 0755 ct-ng && \
		./ct-ng oldconfig && \
		./ct-ng build
	chmod -R +w $(CROSS_DIR)
	test -e $(CROSS_DIR)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	rm -f $(CROSS_DIR)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng

# -----------------------------------------------------------------------------

CROSS_DIR-check:
ifneq ($(wildcard $(CROSS_DIR)),)
	$(call draw_line);
	@echo "Crosstool directory already present."
	@echo
	@echo "You need to run 'make cross-clean' first if you really want to build a new crosstool."
	$(call draw_line);
	@false
endif

# -----------------------------------------------------------------------------

PHONY += crosstool
PHONY += crosstools
PHONY += crosstools-renew
PHONY += $(CROSS_DIR)
PHONY += CROSS_DIR-check
