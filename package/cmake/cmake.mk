################################################################################
#
# cmake
#
################################################################################

CMAKE_VERSION_MAJOR = 3.27
CMAKE_VERSION = $(CMAKE_VERSION_MAJOR).6
CMAKE_DIR = cmake-$(CMAKE_VERSION)
CMAKE_SOURCE = cmake-$(CMAKE_VERSION).tar.gz
CMAKE_SITE = https://cmake.org/files/v$(CMAKE_VERSION_MAJOR)

# -----------------------------------------------------------------------------

# * CMake bundles its dependencies within its sources. This is the
#   reason why the host-cmake package has no dependencies.

HOST_CMAKE_BINARY = $(HOST_DIR)/bin/cmake

# Get rid of -I* options from $(HOST_CPPFLAGS) to prevent that a
# header available in $(HOST_DIR)/include is used instead of a
# CMake internal header, e.g. lzma* headers of the xz package
HOST_CMAKE_CFLAGS = $(shell echo $(HOST_CFLAGS) | sed -r "s%$(HOST_CPPFLAGS)%%")
HOST_CMAKE_CXXFLAGS = $(shell echo $(HOST_CXXFLAGS) | sed -r "s%$(HOST_CPPFLAGS)%%")

# We may be a ccache dependency, so we can't use ccache
HOST_CMAKE_CONFIGURE_ENV = \
	$(HOST_CONFIGURE_ENV) \
	CC="$(HOSTCC_NOCCACHE)" \
	GCC="$(HOSTCC_NOCCACHE)" \
	CXX="$(HOSTCXX_NOCCACHE)"

define HOST_CMAKE_BOOTSTRAP
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(HOST_CMAKE_CONFIGURE_ENV) \
		CFLAGS="$(HOST_CMAKE_CFLAGS)" \
		./bootstrap \
			--prefix=$(HOST_DIR) \
			--docdir=/share/doc \
			--parallel=$(PARALLEL_JOBS) -- \
			-DCMAKE_C_FLAGS="$(HOST_CMAKE_CFLAGS)" \
			-DCMAKE_CXX_FLAGS="$(HOST_CMAKE_CXXFLAGS)" \
			-DCMAKE_EXE_LINKER_FLAGS="$(HOST_LDFLAGS)" \
			-DCMAKE_USE_OPENSSL:BOOL=OFF \
			-DBUILD_CursesDialog=OFF
endef
HOST_CMAKE_PRE_BUILD_HOOKS = HOST_CMAKE_BOOTSTRAP

HOST_CMAKE_INSTALL_ARGS = \
	install/fast

host-cmake: | $(HOST_DIR)
	$(call host-generic-package)
