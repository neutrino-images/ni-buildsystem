################################################################################
#
# qt5webengine-chromium-catapult
#
################################################################################

# the catapult of qt5webengine-chromium is python 2 only; a later one runs
# with python 3 (as in Buildroot); unpacked only, qt5webengine-chromium
# takes it over
QT5WEBENGINE_CHROMIUM_CATAPULT_VERSION = 7534569f99827c0ed4df818254ba7daca4606bca
QT5WEBENGINE_CHROMIUM_CATAPULT_DIR = qt5webengine-chromium-catapult-$(QT5WEBENGINE_CHROMIUM_CATAPULT_VERSION)
QT5WEBENGINE_CHROMIUM_CATAPULT_SOURCE = qt5webengine-chromium-catapult-$(QT5WEBENGINE_CHROMIUM_CATAPULT_VERSION).tar.gz
QT5WEBENGINE_CHROMIUM_CATAPULT_SITE = https://chromium.googlesource.com/catapult/+archive

# the archive of gitiles is called <commit>.tar.gz and has no top directory
define QT5WEBENGINE_CHROMIUM_CATAPULT_DOWNLOAD_ARCHIVE
	if [ ! -f $(DL_DIR)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_SOURCE) ]; then \
		wget --no-check-certificate -t3 -T60 -O $(DL_DIR)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_SOURCE).part \
			$(QT5WEBENGINE_CHROMIUM_CATAPULT_SITE)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_VERSION).tar.gz && \
		mv $(DL_DIR)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_SOURCE).part $(DL_DIR)/$(QT5WEBENGINE_CHROMIUM_CATAPULT_SOURCE); \
	fi
endef
QT5WEBENGINE_CHROMIUM_CATAPULT_PRE_DOWNLOAD_HOOKS += QT5WEBENGINE_CHROMIUM_CATAPULT_DOWNLOAD_ARCHIVE

QT5WEBENGINE_CHROMIUM_CATAPULT_EXTRACT_DIR = $($(PKG)_DIR)

QT5WEBENGINE_CHROMIUM_CATAPULT_KEEP_BUILD_DIR = YES

qt5webengine-chromium-catapult: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_BUILD) $(PKG_NO_INSTALL))
