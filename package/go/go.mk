################################################################################
#
# go
#
################################################################################

GO_VERSION = 1.27.3
GO_DIR = go
GO_SOURCE = go$(GO_VERSION).linux-$(GO_HOST_ARCH).tar.gz
GO_SITE = https://go.dev/dl

# -----------------------------------------------------------------------------

# * Unlike Buildroot, which can bootstrap Go from source in five stages
#   (host-go-src), we only use the pre-built compiler (host-go-bin).

GO_HOST_ARCH_UNAME := $(shell uname -m)

ifeq ($(GO_HOST_ARCH_UNAME),x86_64)
  GO_HOST_ARCH = amd64
else ifeq ($(GO_HOST_ARCH_UNAME),$(filter $(GO_HOST_ARCH_UNAME),aarch64 arm64))
  GO_HOST_ARCH = arm64
else ifeq ($(GO_HOST_ARCH_UNAME),$(filter $(GO_HOST_ARCH_UNAME),i386 i486 i586 i686))
  GO_HOST_ARCH = 386
else ifeq ($(GO_HOST_ARCH_UNAME),$(filter $(GO_HOST_ARCH_UNAME),armv6l armv7l))
  GO_HOST_ARCH = armv6l
else ifeq ($(GO_HOST_ARCH_UNAME),$(filter $(GO_HOST_ARCH_UNAME),ppc64le riscv64 s390x loong64))
  GO_HOST_ARCH = $(GO_HOST_ARCH_UNAME)
endif

# -----------------------------------------------------------------------------

HOST_GO_BINARY = $(HOST_DIR)/bin/go

HOST_GO_ROOT = $(HOST_DIR)/lib/go
HOST_GO_GOPATH = $(HOST_DIR)/share/go-path
HOST_GO_HOST_CACHE = $(HOST_DIR)/share/host-go-cache
HOST_GO_TARGET_CACHE = $(HOST_DIR)/share/go-cache

# Keep the module cache in the download directory, so the downloaded Go
# modules survive a cleanup of the host directory.
HOST_GO_MODCACHE = $(DL_DIR)/go-mod

# Go module proxy used for vendoring. It's the only time where Go is
# allowed to access the network. Falls back to direct downloads.
BS_GOPROXY ?= https://proxy.golang.org,direct

# We pass an empty GOBIN, otherwise "go install: cannot install
# cross-compiled binaries when GOBIN is set"
HOST_GO_COMMON_ENV = \
	GO111MODULE=on \
	GOFLAGS=-mod=vendor \
	GOROOT="$(HOST_GO_ROOT)" \
	GOPATH="$(HOST_GO_GOPATH)" \
	GOCACHE="$(HOST_GO_TARGET_CACHE)" \
	GOMODCACHE="$(HOST_GO_MODCACHE)" \
	GOPROXY=off \
	GOTOOLCHAIN=local \
	PATH=$(PATH) \
	GOBIN=

# -----------------------------------------------------------------------------

# * Go supports Linux kernel 3.2 or later. The Coolstream HD1 (nevis) runs
#   2.6.34, so Go packages can't be built for it.

GO_TARGET_ARCH_SUPPORTS = YES
ifeq ($(firstword $(subst ., ,$(KERNEL_VERSION))),2)
  GO_TARGET_ARCH_SUPPORTS = NO
endif

ifeq ($(TARGET_ARCH),arm)
  GO_GOARCH = arm
  ifeq ($(TARGET_CPU),armv6)
    GO_GOARM = 6
  else
    # armv7-a, armv7ve
    GO_GOARM = 7
  endif
  ifneq ($(findstring -mfloat-abi=soft,$(TARGET_ABI)),)
    GO_GOARM := $(GO_GOARM),softfloat
  endif
else ifeq ($(TARGET_ARCH),aarch64)
  GO_GOARCH = arm64
else ifeq ($(TARGET_ARCH),$(filter $(TARGET_ARCH),i386 i686))
  GO_GOARCH = 386
else ifeq ($(TARGET_ARCH),x86_64)
  GO_GOARCH = amd64
else ifeq ($(TARGET_ARCH),mips)
  ifeq ($(TARGET_ENDIAN),little)
    GO_GOARCH = mipsle
  else
    GO_GOARCH = mips
  endif
  ifneq ($(findstring -msoft-float,$(TARGET_ABI)),)
    GO_GOMIPS = softfloat
  else
    GO_GOMIPS = hardfloat
  endif
else
  GO_TARGET_ARCH_SUPPORTS = NO
endif

# For the convenience of target packages.
HOST_GO_TOOLDIR = $(HOST_GO_ROOT)/pkg/tool/linux_$(GO_GOARCH)
HOST_GO_TARGET_ENV = \
	$(HOST_GO_COMMON_ENV) \
	GOOS="linux" \
	GOARCH=$(GO_GOARCH) \
	$(if $(GO_GOARM),GOARM=$(GO_GOARM)) \
	$(if $(GO_GOMIPS),GOMIPS=$(GO_GOMIPS)) \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	CGO_CFLAGS="$(TARGET_CFLAGS)" \
	CGO_CXXFLAGS="$(TARGET_CXXFLAGS)" \
	CGO_LDFLAGS="$(TARGET_LDFLAGS)" \
	PKG_CONFIG="$(PKG_CONFIG)" \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	GOTOOLDIR="$(HOST_GO_TOOLDIR)"

# For the convenience of host golang packages.
HOST_GO_HOST_ENV = \
	$(HOST_GO_COMMON_ENV) \
	GOOS="" \
	GOARCH="" \
	GOCACHE="$(HOST_GO_HOST_CACHE)" \
	CC="$(HOSTCC_NOCCACHE)" \
	CXX="$(HOSTCXX_NOCCACHE)" \
	CGO_CFLAGS="$(HOST_CFLAGS)" \
	CGO_CXXFLAGS="$(HOST_CXXFLAGS)" \
	CGO_LDFLAGS="$(HOST_LDFLAGS)"

# -----------------------------------------------------------------------------

define HOST_GO_INSTALL
	$(if $(GO_HOST_ARCH),,$(error host-go: no pre-built Go compiler for host architecture $(GO_HOST_ARCH_UNAME)))
	rm -rf $(HOST_GO_ROOT)
	$(INSTALL) -d $(dir $(HOST_GO_ROOT))
	$(INSTALL_COPY) $(PKG_BUILD_DIR) $(HOST_GO_ROOT)
	$(INSTALL) -d $(HOST_DIR)/bin
	ln -sf ../lib/go/bin/go $(HOST_DIR)/bin/go
	ln -sf ../lib/go/bin/gofmt $(HOST_DIR)/bin/gofmt
endef
HOST_GO_INDIVIDUAL_HOOKS += HOST_GO_INSTALL

host-go: | $(HOST_DIR)
	$(call host-individual-package,$(PKG_NO_PATCHES))
