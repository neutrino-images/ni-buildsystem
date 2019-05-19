#
# makefile for tarball download
#
# -----------------------------------------------------------------------------

TZDATA_VER=2018e
$(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz:
	$(WGET) ftp://ftp.iana.org/tz/releases/tzdata$(TZDATA_VER).tar.gz

MTD-UTILS_VER=2.0.2
$(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2:
	$(WGET) ftp://ftp.infradead.org/pub/mtd-utils/mtd-utils-$(MTD-UTILS_VER).tar.bz2

PARTED_VER=3.2
$(ARCHIVE)/parted-$(PARTED_VER).tar.xz:
	$(WGET) http://ftp.gnu.org/gnu/parted/parted-$(PARTED_VER).tar.xz

IPERF_VER=3.1.3
$(ARCHIVE)/iperf-$(IPERF_VER)-source.tar.gz:
	$(WGET) https://iperf.fr/download/source/iperf-$(IPERF_VER)-source.tar.gz

HD-IDLE_VER=1.05
$(ARCHIVE)/hd-idle-$(HD-IDLE_VER).tgz:
	$(WGET) http://downloads.sourceforge.net/project/hd-idle/hd-idle-$(HD-IDLE_VER).tgz

NTP_VER=4.2.8
$(ARCHIVE)/ntp-$(NTP_VER).tar.gz:
	$(WGET) http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-$(NTP_VER).tar.gz

USHARE_VER=1.1a
$(ARCHIVE)/ushare-$(USHARE_VER).tar.bz2:
	$(WGET) http://ushare.geexbox.org/releases/ushare-$(USHARE_VER).tar.bz2

HDPARM_VER=9.54
$(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/hdparm/files/hdparm/hdparm-$(HDPARM_VER).tar.gz

LIBUPNP_VER=1.6.22
$(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VER)/libupnp-$(LIBUPNP_VER).tar.bz2

WPA_SUPP_VER=0.7.3
$(ARCHIVE)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz:
	$(WGET) https://ftp.osuosl.org/pub/blfs/conglomeration/wpa_supplicant/wpa_supplicant-$(WPA_SUPP_VER).tar.gz

LIBGD_VER=2.2.5
$(ARCHIVE)/libgd-$(LIBGD_VER).tar.xz:
	$(WGET) https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VER)/libgd-$(LIBGD_VER).tar.xz

DJMOUNT_VER=0.71
$(ARCHIVE)/djmount-$(DJMOUNT_VER).tar.gz:
	$(WGET) http://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)/djmount-$(DJMOUNT_VER).tar.gz

FUSE_VER=2.9.8
$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(WGET) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

OPENVPN_VER=2.4.6
$(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz:
	$(WGET) http://swupdate.openvpn.org/community/releases/openvpn-$(OPENVPN_VER).tar.xz

GCC_VER=4.9-2017.01
CUSTOM_GCC_VER=linaro-$(GCC_VER)
CUSTOM_GCC=$(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz
$(ARCHIVE)/gcc-linaro-$(GCC_VER).tar.xz:
	$(WGET) https://releases.linaro.org/components/toolchain/gcc-linaro/$(GCC_VER)/gcc-linaro-$(GCC_VER).tar.xz

OPENSSH_VER=7.9p1
$(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz:
	$(WGET) https://ftp.fau.de/pub/OpenBSD/OpenSSH/portable/openssh-$(OPENSSH_VER).tar.gz

INADYN_VER=2.4
$(ARCHIVE)/inadyn-$(INADYN_VER).tar.xz:
	$(WGET) https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)/inadyn-$(INADYN_VER).tar.xz

COREUTILS_VER=8.30
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
AUTOFS5_MICRO=4
AUTOFS5_VER=$(AUTOFS5_MAJOR).$(AUTOFS5_MINOR).$(AUTOFS5_MICRO)
$(ARCHIVE)/autofs-$(AUTOFS5_VER).tar.gz:
	$(WGET) https://www.kernel.org/pub/linux/daemons/autofs/v$(AUTOFS5_MAJOR)/autofs-$(AUTOFS5_VER).tar.gz

ZLIB_VER=1.2.11
$(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz:
	$(WGET) http://zlib.net/zlib-$(ZLIB_VER).tar.gz

LIBPNG_VER=1.6.36
$(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz:
	$(WGET) http://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VER)/libpng-$(LIBPNG_VER).tar.xz

LIBVORBISIDEC_VER=1.2.1+git20180316
$(ARCHIVE)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz:
	$(WGET) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz

LIBOGG_VER=1.3.3
$(ARCHIVE)/libogg-$(LIBOGG_VER).tar.xz:
	$(WGET) http://downloads.xiph.org/releases/ogg/libogg-$(LIBOGG_VER).tar.xz

LIBMAD_VER=0.15.1b
$(ARCHIVE)/libmad-$(LIBMAD_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libmad/$(LIBMAD_VER)/libmad-$(LIBMAD_VER).tar.gz

LIBICONV_VER=1.13.1
$(ARCHIVE)/libiconv-$(LIBICONV_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/gnu/libiconv/libiconv-$(LIBICONV_VER).tar.gz

GIFLIB_VER=5.1.4
$(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/giflib/files/giflib-$(GIFLIB_VER).tar.bz2

LIBCURL_VER=7.61.1
$(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2:
	$(WGET) http://curl.haxx.se/download/curl-$(LIBCURL_VER).tar.bz2

DROPBEAR_VER=2018.76
$(ARCHIVE)/dropbear-$(DROPBEAR_VER).tar.bz2:
	$(WGET) http://matt.ucc.asn.au/dropbear/releases/dropbear-$(DROPBEAR_VER).tar.bz2

FBSHOT_VER=0.3
$(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz:
	$(WGET) http://distro.ibiblio.org/amigolinux/download/Utils/fbshot/fbshot-$(FBSHOT_VER).tar.gz

FREETYPE_VER=2.9.1
$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(WGET) https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)/freetype-$(FREETYPE_VER).tar.bz2

OPENSSL_VER=1.0.2q
$(ARCHIVE)/openssl-$(OPENSSL_VER).tar.gz:
	$(WGET) http://www.openssl.org/source/openssl-$(OPENSSL_VER).tar.gz

LIBNCURSES_VER=6.1
$(ARCHIVE)/ncurses-$(LIBNCURSES_VER).tar.gz:
	$(WGET) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(LIBNCURSES_VER).tar.gz

NTFS3G_VER=2017.3.23
$(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz:
	$(WGET) https://tuxera.com/opensource/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz

PROCPS-NG_VER=3.3.15
$(ARCHIVE)/procps-ng-$(PROCPS-NG_VER).tar.xz:
	$(WGET) http://sourceforge.net/projects/procps-ng/files/Production/procps-ng-$(PROCPS-NG_VER).tar.xz

SAMBA33_VER=3.3.16
$(ARCHIVE)/samba-$(SAMBA33_VER).tar.gz:
	$(WGET) https://download.samba.org/pub/samba/samba-$(SAMBA33_VER).tar.gz

SAMBA36_VER=3.6.25
$(ARCHIVE)/samba-$(SAMBA36_VER).tar.gz:
	$(WGET) https://download.samba.org/pub/samba/stable/samba-$(SAMBA36_VER).tar.gz

E2FSPROGS_VER=1.44.5
ifeq ($(BOXTYPE), coolstream)
# formatting ext4 failes with newer versions
E2FSPROGS_VER=1.43.8
endif
$(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v$(E2FSPROGS_VER)/e2fsprogs-$(E2FSPROGS_VER).tar.gz

GNULIB_VER=20140202
$(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz:
	$(WGET) http://erislabs.net/ianb/projects/gnulib/gnulib-$(GNULIB_VER)-stable.tar.gz

SLINGSHOT_VER=6
$(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz:
	$(WGET) https://github.com/gvvaughan/slingshot/archive/v$(SLINGSHOT_VER).tar.gz

LUA_ABIVER=5.2
LUA_VER=$(LUA_ABIVER).4
$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

LUAPOSIX_VER=31
$(ARCHIVE)/v$(LUAPOSIX_VER).tar.gz:
	$(WGET) https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz

EXPAT_VER=2.2.6
$(ARCHIVE)/expat-$(EXPAT_VER).tar.bz2:
	$(WGET) http://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)/expat-$(EXPAT_VER).tar.bz2

LUAEXPAT_VER=1.3.0
$(ARCHIVE)/luaexpat-$(LUAEXPAT_VER).tar.gz:
	$(WGET) http://matthewwild.co.uk/projects/luaexpat/luaexpat-$(LUAEXPAT_VER).tar.gz

LUACURL_VER=v3
$(ARCHIVE)/Lua-cURL$(LUACURL_VER).tar.xz:
	$(WGET) http://neutrino-images.de/neutrino-images/archives/Lua-cURL$(LUACURL_VER).tar.xz

LIBBLURAY_VER=0.9.2
$(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/libbluray-$(LIBBLURAY_VER).tar.bz2

LIBASS_VER=0.14.0
$(ARCHIVE)/libass-$(LIBASS_VER).tar.xz:
	$(WGET) https://github.com/libass/libass/releases/download/$(LIBASS_VER)/libass-$(LIBASS_VER).tar.xz

LIBBDPLUS_VER=0.1.2
$(ARCHIVE)/libbdplus-$(LIBBDPLUS_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
	
LIBAACS_VER=0.9.0
$(ARCHIVE)/libaacs-$(LIBAACS_VER).tar.bz2:
	$(WGET) ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)/libaacs-$(LIBAACS_VER).tar.bz2

CONFUSE_VER=3.2.2
$(ARCHIVE)/confuse-$(CONFUSE_VER).tar.xz:
	$(WGET) https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VER)/confuse-$(CONFUSE_VER).tar.xz

FUSE_EXFAT_VER=1.2.8
$(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz:
	$(WGET) https://github.com/relan/exfat/releases/download/v$(FUSE_EXFAT_VER)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz
