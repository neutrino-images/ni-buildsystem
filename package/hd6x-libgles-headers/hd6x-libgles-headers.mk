################################################################################
#
# hd6x-libgles-headers
#
################################################################################

HD6X_LIBGLES_HEADERS_VERSION =
HD6X_LIBGLES_HEADERS_DIR = libgles-mali-utgard-headers
HD6X_LIBGLES_HEADERS_SOURCE = libgles-mali-utgard-headers.zip
HD6X_LIBGLES_HEADERS_SITE = https://github.com/HD-Digital/meta-gfutures/raw/release-6.2/recipes-bsp/mali/files

# fix non-existing subdir in zip
HD6X_LIBGLES_HEADERS_EXTRACT_DIR = $($(PKG)_DIR)

define HD6X_LIBGLES_HEADERS_INSTALL
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/* $(TARGET_includedir)
endef
HD6X_LIBGLES_HEADERS_INDIVIDUAL_HOOKS += HD6X_LIBGLES_HEADERS_INSTALL

hd6x-libgles-headers: | $(TARGET_DIR)
	$(call individual-package)
