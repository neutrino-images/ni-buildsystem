#
# makefile to install system scripts
#
# -----------------------------------------------------------------------------

init-scripts: \
	$(TARGET_DIR)/etc/init.d/globals \
	$(TARGET_DIR)/etc/init.d/functions \
	$(TARGET_DIR)/etc/init.d/camd \
	$(TARGET_DIR)/etc/init.d/camd_datefix \
	$(TARGET_DIR)/etc/init.d/coredump \
	$(TARGET_DIR)/etc/init.d/crond \
	$(TARGET_DIR)/etc/init.d/hostname \
	$(TARGET_DIR)/etc/init.d/inetd

$(TARGET_DIR)/etc/init.d/globals:
	install -D -m 0644 $(IMAGEFILES)/scripts/init.globals $@

$(TARGET_DIR)/etc/init.d/functions:
	install -D -m 0644 $(IMAGEFILES)/scripts/init.functions $@

$(TARGET_DIR)/etc/init.d/camd:
	install -D -m 0755 $(IMAGEFILES)/scripts/camd.init $@
	ln -sf camd $(TARGET_DIR)/etc/init.d/S99camd
	ln -sf camd $(TARGET_DIR)/etc/init.d/K01camd

$(TARGET_DIR)/etc/init.d/camd_datefix:
	install -D -m 0755 $(IMAGEFILES)/scripts/camd_datefix.init $@

$(TARGET_DIR)/etc/init.d/coredump:
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
	install -D -m 0755 $(IMAGEFILES)/scripts/coredump.init $@
endif

$(TARGET_DIR)/etc/init.d/crond:
	install -D -m 0755 $(IMAGEFILES)/scripts/crond.init $@

$(TARGET_DIR)/etc/init.d/hostname:
	install -D -m 0755 $(IMAGEFILES)/scripts/hostname.init $@

$(TARGET_DIR)/etc/init.d/inetd:
	install -D -m 0755 $(IMAGEFILES)/scripts/inetd.init $@

# -----------------------------------------------------------------------------

scripts: \
	$(TARGET_DIR)/sbin/service \
	$(TARGET_DIR)/sbin/flash_eraseall \
	$(TARGET_DIR)/share/udhcpc/default.script

$(TARGET_DIR)/sbin/service:
	install -D -m 0755 $(IMAGEFILES)/scripts/service $@

$(TARGET_DIR)/sbin/flash_eraseall:
ifeq ($(BOXTYPE), coolstream)
	install -D -m 0755 $(IMAGEFILES)/scripts/flash_eraseall $@
endif

$(TARGET_DIR)/share/udhcpc/default.script:
	install -D -m 0755 $(IMAGEFILES)/scripts/udhcpc-default.script $@
