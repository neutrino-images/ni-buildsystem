################################################################################
#
# openvpn
#
################################################################################

OPENVPN_VERSION = 2.5.0
OPENVPN_DIR = openvpn-$(OPENVPN_VERSION)
OPENVPN_SOURCE = openvpn-$(OPENVPN_VERSION).tar.xz
OPENVPN_SITE = http://build.openvpn.net/downloads/releases

OPENVPN_DEPENDENCIES = lzo openssl

OPENVPN_CONF_ENV = \
	NETSTAT="/bin/netstat" \
	IFCONFIG="/sbin/ifconfig" \
	IPROUTE="/sbin/ip" \
	ROUTE="/sbin/route"

OPENVPN_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--infodir=$(REMOVE_infodir) \
	--enable-shared \
	--disable-static \
	--enable-small \
	--enable-management \
	--disable-debug \
	--disable-selinux \
	--disable-plugins \
	--disable-pkcs11

openvpn: | $(TARGET_DIR)
	$(call autotools-package)
