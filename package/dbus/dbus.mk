################################################################################
#
# dbus
#
################################################################################

DBUS_VERSION = 1.14.10
DBUS_DIR = dbus-$(DBUS_VERSION)
DBUS_SOURCE = dbus-$(DBUS_VERSION).tar.xz
DBUS_SITE = https://dbus.freedesktop.org/releases/dbus

DBUS_DEPENDENCIES = expat

DBUS_CONF_OPTS = \
	--disable-tests \
	--disable-xml-docs \
	--disable-doxygen-docs \
	--disable-ducktype-docs \
	--disable-systemd \
	--disable-selinux \
	--disable-apparmor \
	--disable-libaudit \
	--disable-inotify \
	--disable-kqueue \
	--disable-launchd \
	--without-x \
	--enable-abstract-sockets \
	--with-system-socket=/run/dbus/system_bus_socket

dbus: | $(TARGET_DIR)
	$(call autotools-package)
