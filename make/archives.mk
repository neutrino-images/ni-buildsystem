# makefile for tarball download

LIBGCRYPT_VER=1.7.6
$(ARCHIVE)/libgcrypt-$(LIBGCRYPT_VER).tar.gz:
	$(WGET) ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-$(LIBGCRYPT_VER).tar.gz

LIBGPG-ERROR_VER=1.26
$(ARCHIVE)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2:
	$(WGET) ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2

TZDATA_VER=2016j
$(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(TZDATA_VER).tar.gz

TZCODE_VER=2016j
$(ARCHIVE)/tzcode$(TZCODE_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzcode$(TZCODE_VER).tar.gz

PUGIXML_VER=1.8
$(ARCHIVE)/pugixml-$(PUGIXML_VER).tar.gz:
	$(WGET) http://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)/pugixml-$(PUGIXML_VER).tar.gz

LIBXML2_VER=2.9.4
$(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz:
	$(WGET) ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_VER).tar.gz

NFS-UTILS_VER=1.3.3
$(ARCHIVE)/nfs-utils-$(NFS-UTILS_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/nfs/files/nfs-utils/$(NFS-UTILS_VER)/nfs-utils-$(NFS-UTILS_VER).tar.bz2

RPCBIND_VER=0.2.3
$(ARCHIVE)/rpcbind-$(RPCBIND_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)/rpcbind-$(RPCBIND_VER).tar.bz2

LIBTIRPC_VER=1.0.1
$(ARCHIVE)/libtirpc-$(LIBTIRPC_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VER)/libtirpc-$(LIBTIRPC_VER).tar.bz2

$(ARCHIVE)/strace-4.8.tar.xz:
	$(WGET) http://sourceforge.net/projects/strace/files/strace/4.8/strace-4.8.tar.xz

PARTED_VER=3.2
$(ARCHIVE)/parted-$(PARTED_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz

IPERF_VER=3.1.3
$(ARCHIVE)/iperf-$(IPERF_VER)-source.tar.gz:
	$(WGET) https://iperf.fr/download/source/iperf-$(IPERF_VER)-source.tar.gz

HDIDLE_VER=1.04
$(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz:
	$(WGET) http://downloads.sourceforge.net/project/hd-idle/hd-idle-$(HDIDLE_VER).tgz

NTP_VER=4.2.8
$(ARCHIVE)/ntp-$(NTP_VER).tar.gz:
	$(WGET) http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-$(NTP_VER).tar.gz

USHARE_VER=1.1a
$(ARCHIVE)/ushare-$(USHARE_VER).tar.bz2:
	$(WGET) http://ushare.geexbox.org/releases/ushare-$(USHARE_VER).tar.bz2

HDPARM_VER=9.50
$(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/hdparm/files/hdparm/hdparm-$(HDPARM_VER).tar.gz

LIBUPNP_VER=1.6.21
$(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VER)/libupnp-$(LIBUPNP_VER).tar.bz2

WPA_SUPP_VER=0.7.3
$(ARCHIVE)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz:
	$(WGET) http://hostap.epitest.fi/releases/wpa_supplicant-$(WPA_SUPP_VER).tar.gz

LIBGD_VER=2.2.4
$(ARCHIVE)/libgd-$(LIBGD_VER).tar.xz:
	$(WGET) https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VER)/libgd-$(LIBGD_VER).tar.xz

DJMOUNT_VER=0.71
$(ARCHIVE)/djmount-$(DJMOUNT_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)/djmount-$(DJMOUNT_VER).tar.gz

FUSE_VER=2.9.7
$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(WGET) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

OPENVPN_VER=2.4.2
$(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz:
	$(WGET) http://swupdate.openvpn.org/community/releases/openvpn-$(OPENVPN_VER).tar.xz

GCC_VER=4.9-2017.01
CUSTOM_GCC_VER=linaro-$(GCC_VER)
CUSTOM_GCC=$(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz
$(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz:
	$(WGET) https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC_VER)/gcc-linaro-$(GCC_VER).tar.xz

OPENSSH_VER=7.5p1
$(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz:
	$(WGET) https://ftp.fau.de/pub/OpenBSD/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz

INADYN_VER=2.1
$(ARCHIVE)/inadyn-$(INADYN_VER).tar.xz:
	$(WGET) https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)/inadyn-$(INADYN_VER).tar.xz

COREUTILS_VER=8.27
$(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/coreutils/coreutils-$(COREUTILS_VER).tar.xz

SG3-UTILS_VER=1.42
$(ARCHIVE)/sg3_utils-$(SG3-UTILS_VER).tar.xz:
	$(WGET) http://sg.danny.cz/sg/p/sg3_utils-$(SG3-UTILS_VER).tar.xz

LIBUSB_COMPAT_VER=0.1.5
LIBUSB_COMPAT_MAJ=0.1
$(ARCHIVE)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2:
	$(WGET) http://downloads.sourceforge.net/project/libusb/libusb-compat-$(LIBUSB_COMPAT_MAJ)/libusb-compat-$(LIBUSB_COMPAT_VER)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2

LIBUSB_VER=1.0.21
LIBUSB_MAJ=1.0
$(ARCHIVE)/libusb-$(LIBUSB_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/libusb/files/libusb-$(LIBUSB_MAJ)/libusb-$(LIBUSB_VER)/libusb-$(LIBUSB_VER).tar.bz2

VSFTPD_VER=3.0.3
$(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz:
	$(WGET) https://security.appspot.com/downloads/vsftpd-$(VSFTPD_VER).tar.gz

AUTOFS5_MAJOR=5
AUTOFS5_MINOR=1
AUTOFS5_MICRO=3
AUTOFS5_VER=$(AUTOFS5_MAJOR).$(AUTOFS5_MINOR).$(AUTOFS5_MICRO)
$(ARCHIVE)/autofs-$(AUTOFS5_VER).tar.gz:
	$(WGET) https://www.kernel.org/pub/linux/daemons/autofs/v$(AUTOFS5_MAJOR)/autofs-$(AUTOFS5_VER).tar.gz

ZLIB_VER=1.2.11
$(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz:
	$(WGET) http://zlib.net/zlib-$(ZLIB_VER).tar.gz

LIBPNG_VER=1.6.31
$(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz:
	$(WGET) http://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VER)/libpng-$(LIBPNG_VER).tar.xz

LIBVORBISIDEC_VER=1.0.2+svn18153
$(ARCHIVE)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz

LIBOGG_VER=1.3.2
$(ARCHIVE)/libogg-$(LIBOGG_VER).tar.xz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(LIBOGG_VER).tar.xz

LIBMAD_VER=0.15.1b
$(ARCHIVE)/libmad-$(LIBMAD_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(LIBMAD_VER)/libmad-$(LIBMAD_VER).tar.gz

LIBICONV_VER=1.15
ibiconv-$(LIBICONV_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(LIBICONV_VER).tar.gz

LIBJPEG-TURBO_VER=1.5.2
$(ARCHIVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz:
	$(WGET) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO_VER)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz

GIFLIB_VER=5.1.4
$(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/giflib-$(GIFLIB_VER).tar.bz2

LIBCURL_VER=7.55.1
$(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-$(LIBCURL_VER).tar.bz2

DROPBEAR_VER=2017.75
$(ARCHIVE)/dropbear-$(DROPBEAR_VER).tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-$(DROPBEAR_VER).tar.bz2

FBSHOT_VER=0.3
$(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz:
	$(WGET) http://distro.ibiblio.org/amigolinux/download/Utils/fbshot/fbshot-$(FBSHOT_VER).tar.gz

FREETYPE_VER=2.8
$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(WGET) https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)/freetype-$(FREETYPE_VER).tar.bz2

OPENSSL_VER=1.0.2l
$(ARCHIVE)/openssl-$(OPENSSL_VER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL_VER).tar.gz

LIBNCURSES_VER=6.0
$(ARCHIVE)/ncurses-$(LIBNCURSES_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(LIBNCURSES_VER).tar.gz

NTFS3G_VER=2017.3.23
$(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz:
	$(WGET) https://tuxera.com/opensource/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz

PROCPS-NG_VER=3.3.12
$(ARCHIVE)/procps-ng-$(PROCPS-NG_VER).tar.xz:
	$(WGET) http://sourceforge.net/projects/procps-ng/files/Production/procps-ng-$(PROCPS-NG_VER).tar.xz

BUSYBOX_MAJOR=1
BUSYBOX_MINOR=27
BUSYBOX_MICRO=2
BUSYBOX_VER=$(BUSYBOX_MAJOR).$(BUSYBOX_MINOR).$(BUSYBOX_MICRO)
$(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2:
	$(WGET) http://busybox.net/downloads/busybox-$(BUSYBOX_VER).tar.bz2

SAMBA33_VER=3.3.16
$(ARCHIVE)/samba-$(SAMBA33_VER).tar.gz:
	$(WGET) https://download.samba.org/pub/samba/samba-$(SAMBA33_VER).tar.gz

SAMBA36_VER=3.6.25
$(ARCHIVE)/samba-$(SAMBA36_VER).tar.gz:
	$(WGET) https://download.samba.org/pub/samba/stable/samba-$(SAMBA36_VER).tar.gz

E2FSPROGS_VER=1.43.5
$(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz

SMARTMON_VER=6.5
$(ARCHIVE)/smartmontools-$(SMARTMON_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/smartmontools/smartmontools/$(SMARTMON_VER)/smartmontools-$(SMARTMON_VER).tar.gz

GDB_VER=7.12.1
$(ARCHIVE)/gdb-$(GDB_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-$(GDB_VER).tar.xz

NANO_VER=2.8.6
NANO_VER_MAJ=2.8
$(ARCHIVE)/nano-$(NANO_VER).tar.gz:
	$(WGET) http://www.nano-editor.org/dist/v$(NANO_VER_MAJ)/nano-$(NANO_VER).tar.gz

MINICOM_VER=2.7
$(ARCHIVE)/minicom-$(MINICOM_VER).tar.gz:
	$(WGET) http://fossies.org/linux/misc/minicom-$(MINICOM_VER).tar.gz

LZO_VER=2.10
$(ARCHIVE)/lzo-$(LZO_VER).tar.gz:
	$(WGET) https://fossies.org/linux/misc/lzo-$(LZO_VER).tar.gz

GNULIB_VER=20140202
$(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz:
	$(WGET) http://erislabs.net/ianb/projects/gnulib/gnulib-$(GNULIB_VER)-stable.tar.gz

SLINGSHOT_VER=6
$(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz:
	$(WGET) https://github.com/gvvaughan/slingshot/archive/v$(SLINGSHOT_VER).tar.gz

LIBSIGCPP_MAJOR=2
LIBSIGCPP_MINOR=4
LIBSIGCPP_MICRO=1
LIBSIGCPP_VER=$(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR).$(LIBSIGCPP_MICRO)
$(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR)/libsigc++-$(LIBSIGCPP_VER).tar.xz

LUA_ABIVER=5.2
LUA_VER=$(LUA_ABIVER).3
$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

LUAPOSIX_VER=31
$(ARCHIVE)/v$(LUAPOSIX_VER).tar.gz:
	$(WGET) https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz

EXPAT_VER=2.1.0
$(ARCHIVE)/expat-$(EXPAT_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/expat-$(EXPAT_VER).tar.gz

LUA_EXPAT_VER=1.2.0
$(ARCHIVE)/luaexpat-$(LUA_EXPAT_VER).tar.gz:
	$(WGET) http://matthewwild.co.uk/projects/luaexpat/luaexpat-$(LUA_EXPAT_VER).tar.gz

LUACURL_VER=v3
$(ARCHIVE)/Lua-cURL$(LUACURL_VER).tar.xz:
	$(WGET) http://neutrino-images.de/neutrino-images/archives/Lua-cURL$(LUACURL_VER).tar.xz

LIBBLURAY_VER=0.9.2
$(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/libbluray-$(LIBBLURAY_VER).tar.bz2

LIBASS_VER=0.13.7
$(ARCHIVE)/libass-$(LIBASS_VER).tar.xz:
	$(WGET) https://github.com/libass/libass/releases/download/$(LIBASS_VER)/libass-$(LIBASS_VER).tar.xz

PKGCONF_VER=0.29.2
$(ARCHIVE)/pkg-config-$(PKGCONF_VER).tar.gz:
	$(WGET) https://pkg-config.freedesktop.org/releases/pkg-config-$(PKGCONF_VER).tar.gz
	
LIBBDPLUS_VER=0.1.2
$(ARCHIVE)/libbdplus-$(LIBBDPLUS_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
	
LIBAACS_VER=0.8.1
$(ARCHIVE)/libaacs-$(LIBAACS_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)/libaacs-$(LIBAACS_VER).tar.bz2

BC_VER=1.06
$(ARCHIVE)/bc-$(BC_VER).tar.gz:
	$(WGET) ftp://ftp.gnu.org/gnu/bc/bc-$(BC_VER).tar.gz

BASH_MAJOR=4
BASH_MINOR=4
BASH_MICRO=0
BASH_VER=$(BASH_MAJOR).$(BASH_MINOR)
ifneq ($(BASH_MICRO), 0)
  BASH_VER=$(BASH_VER).$(BASH_MICRO)
endif
$(ARCHIVE)/bash-$(BASH_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/bash/bash-$(BASH_VER).tar.gz

VALGRIND_VER=3.10.1
$(ARCHIVE)/valgrind-$(VALGRIND_VER).tar.bz2:
	$(WGET) http://valgrind.org/downloads/valgrind-$(VALGRIND_VER).tar.bz2

CORTEX-STRINGS_VER=48fd30c346ff2ab14ca574b770b5c1bcbefadba8
$(ARCHIVE)/cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2:
	get-git-archive.sh http://git.linaro.org/git-ro/toolchain/cortex-strings.git $(CORTEX-STRINGS_VER) $(notdir $@) $(ARCHIVE)

U_BOOT_VER=2015.01
$(ARCHIVE)/u-boot-$(U_BOOT_VER).tar.bz2:
	$(WGET) ftp://ftp.denx.de/pub/u-boot/u-boot-$(U_BOOT_VER).tar.bz2

DOSFSTOOLS_VER=4.1
$(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz:
	$(WGET) https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)/dosfstools-$(DOSFSTOOLS_VER).tar.xz

GIT_VER=a3b75b3ccbc0f8128937d3b393837c2a74f2b662
$(ARCHIVE)/git-$(GIT_VER).tar.bz2:
	get-git-archive.sh $(GITHUB)/git/git $(GIT_VER) $(notdir $@) $(ARCHIVE)

LESS_VER=487
$(ARCHIVE)/less-$(LESS_VER).tar.gz:
	$(WGET) http://www.greenwoodsoftware.com/less/less-$(LESS_VER).tar.gz

CONFUSE_VER=3.0
$(ARCHIVE)/confuse-$(CONFUSE_VER).tar.xz:
	$(WGET) https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VER)/confuse-$(CONFUSE_VER).tar.xz

ITE_VER=1.8.0
$(ARCHIVE)/libite-$(ITE_VER).tar.xz:
	$(WGET) https://github.com/troglobit/libite/releases/download/v$(ITE_VER)/libite-$(ITE_VER).tar.xz

FUSE_EXFAT_VER=1.2.6
$(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz:
	$(WGET) https://github.com/relan/exfat/releases/download/v$(FUSE_EXFAT_VER)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz

EXFAT_UTILS_VER=1.2.6
$(ARCHIVE)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz:
	$(WGET) https://github.com/relan/exfat/releases/download/v$(EXFAT_UTILS_VER)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz

FRIBIDI_VER = 0.19.7
$(ARCHIVE)/fribidi-$(FRIBIDI_VER).tar.bz2:
	$(WGET) https://fribidi.org/download/fribidi-$(FRIBIDI_VER).tar.bz2

MC-VER=4.8.19
$(ARCHIVE)/mc-$(MC-VER).tar.xz:
	$(WGET) http://ftp.midnight-commander.org/mc-$(MC-VER).tar.xz

LIBFFI_VER=3.2.1
$(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz:
	$(WGET) ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz

GLIB_MAJOR=2
GLIB_MINOR=53
GLIB_MICRO=4
GLIB_VER=$(GLIB_MAJOR).$(GLIB_MINOR).$(GLIB_MICRO)
$(ARCHIVE)/glib-$(GLIB_VER).tar.xz:
	$(WGET) http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB_MAJOR).$(GLIB_MINOR)/glib-$(GLIB_VER).tar.xz

GETTEXT_VERSION=0.19.8.1
$(ARCHIVE)/gettext-$(GETTEXT_VERSION).tar.xz:
	$(WGET) ftp://ftp.gnu.org/gnu/gettext/gettext-$(GETTEXT_VERSION).tar.xz

WGET_VER=1.19.1
$(ARCHIVE)/wget-$(WGET_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/wget/wget-$(WGET_VER).tar.gz
