################################################################################
#
# qt5webengine-chromium
#
################################################################################

# src/3rdparty of qt5webengine, a submodule the archive of the tag lacks:
# chromium (and gn) of KDE's branch, the commit Buildroot uses for 5.15.19;
# unpacked and patched only, qt5webengine takes it over
QT5WEBENGINE_CHROMIUM_VERSION = 6d29e9cfcfffa7632cc3858ceaf8940677ba9c91
QT5WEBENGINE_CHROMIUM_DIR = qtwebengine-chromium-$(QT5WEBENGINE_CHROMIUM_VERSION)
QT5WEBENGINE_CHROMIUM_SOURCE = qtwebengine-chromium-$(QT5WEBENGINE_CHROMIUM_VERSION).tar.bz2
QT5WEBENGINE_CHROMIUM_SITE = $(QT5_SITE)/qtwebengine-chromium/-/archive/$(QT5WEBENGINE_CHROMIUM_VERSION)

QT5WEBENGINE_CHROMIUM_DEPENDENCIES = qt5webengine-chromium-catapult

define QT5WEBENGINE_CHROMIUM_COPY_CATAPULT
	rm -rf $(PKG_BUILD_DIR)/chromium/third_party/catapult
	cp -a $(BUILD_DIR)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_DIR) $(PKG_BUILD_DIR)/chromium/third_party/catapult
endef
QT5WEBENGINE_CHROMIUM_POST_PATCH_HOOKS += QT5WEBENGINE_CHROMIUM_COPY_CATAPULT

QT5WEBENGINE_CHROMIUM_KEEP_BUILD_DIR = YES

qt5webengine-chromium: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_BUILD) $(PKG_NO_INSTALL))
