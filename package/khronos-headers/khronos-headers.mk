################################################################################
#
# khronos-headers
#
################################################################################

# EGL, KHR and GLES2/GLES3 API headers of the Khronos registries, for the
# binary GLES drivers that ship without headers (hd51 v3ddriver)

KHRONOS_HEADERS_VERSION = 00de6df1cc738a7a9e138680273363cde5345123
KHRONOS_HEADERS_DIR = EGL-Registry.git
KHRONOS_HEADERS_SOURCE = EGL-Registry.git
KHRONOS_HEADERS_SITE = https://github.com/KhronosGroup
KHRONOS_HEADERS_SITE_METHOD = git

KHRONOS_HEADERS_GLES_VERSION = 6af574a14089ccfee87efe230ebcdd8742859813
KHRONOS_HEADERS_GLES_SOURCE = OpenGL-Registry.git

define KHRONOS_HEADERS_GET_GLES
	support/scripts/get-git-source.sh $(KHRONOS_HEADERS_SITE)/$(KHRONOS_HEADERS_GLES_SOURCE) $(DL_DIR)/$(KHRONOS_HEADERS_GLES_SOURCE)
	rm -rf $(PKG_BUILD_DIR)/gles
	cp -a $(DL_DIR)/$(KHRONOS_HEADERS_GLES_SOURCE) $(PKG_BUILD_DIR)/gles
	$(CD) $(PKG_BUILD_DIR)/gles; git checkout -q $(KHRONOS_HEADERS_GLES_VERSION)
endef
KHRONOS_HEADERS_INDIVIDUAL_HOOKS += KHRONOS_HEADERS_GET_GLES

define KHRONOS_HEADERS_INSTALL
	$(INSTALL) -d $(TARGET_includedir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/api/EGL $(PKG_BUILD_DIR)/api/KHR $(TARGET_includedir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/gles/api/GLES2 $(PKG_BUILD_DIR)/gles/api/GLES3 $(TARGET_includedir)
endef
KHRONOS_HEADERS_INDIVIDUAL_HOOKS += KHRONOS_HEADERS_INSTALL

khronos-headers: | $(TARGET_DIR)
	$(call individual-package)
