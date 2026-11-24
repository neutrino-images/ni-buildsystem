################################################################################
#
# qt5 - common settings of the Qt 5 modules
#
################################################################################

QT5_VERSION_MAJOR = 5.15
QT5_VERSION = $(QT5_VERSION_MAJOR).19
# the 5.15 LTS branches KDE maintains: newer than the last tarballs of
# download.qt.io (5.15.16), and only there qt5webengine builds with python 3
QT5_SITE = https://invent.kde.org/qt/qt

# these are git snapshots, not release tarballs: the forwarding headers
# are not generated yet, configure/qmake runs syncqt.pl for a source dir
# with a .git; the branches still say 5.15.x in MODULE_VERSION
define QT5_SYNC_QT_HEADERS
	$(SED) '/^MODULE_VERSION/s/$(subst .,\.,$(QT5_VERSION_MAJOR))\.[0-9]*/$(QT5_VERSION)/' \
		$(PKG_BUILD_DIR)/.qmake.conf
	touch $(PKG_BUILD_DIR)/.git
endef

# qmake of the cross build of qt5base, a host tool
QT5_QMAKE = $(HOST_DIR)/bin/qmake

# a Qt module or application built with that qmake; make install puts it
# into the target tree, the sysroot qt5base was configured with
define QT5_QMAKE_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(QT5_QMAKE) $($(PKG)_QMAKE_OPTS)
endef

define QT5_QMAKE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) install
endef

# gcc/g++ wrappers adding -w into a directory put first in PATH, for what is
# built with the host compiler (qtbase's qmake and bootstrap tools,
# chromium's host toolchains): warnings stay out of the output, errors not.
# They call the system compiler by its path; a gcc/g++ in PATH that is a
# ccache link is kept as "ccache <compiler>" (ccache called through the link
# would look up gcc/g++ in PATH, find the wrapper and loop)
define QT5_HOST_COMPILER_WRAPPERS # (directory)
	$(INSTALL) -d $(1)
	for c in gcc g++; do \
		real=$$(PATH=/usr/local/bin:/usr/bin:/bin command -v $$c); \
		case "$$(readlink -f "$$(command -v $$c)")" in \
			*/ccache) real="$$(readlink -f "$$(command -v $$c)") $$real" ;; \
		esac; \
		sed "s|@COMPILER@|$$real|" $(PACKAGE_DIR)/qt5/host-wrapper.in > $(1)/$$c; \
		chmod 755 $(1)/$$c; \
	done
endef

# the modules: package/qt5/<module>
include $(sort $(wildcard package/qt5/*/*.mk))
