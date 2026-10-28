################################################################################
#
# Golang package infrastructure
#
################################################################################

# golang-module-path(url): infer the root Go module path
# (domain/vendor/software) from the upstream URL of the project, e.g.
#   https://github.com/foo/bar/archive/v1.0 -> github.com/foo/bar
#   https://github.com/foo/bar.git -> github.com/foo/bar
golang-module-path = $(patsubst %.git,%,$(subst $(space),/,$(wordlist 1,3,$(subst /, ,$(patsubst http://%,%,$(patsubst https://%,%,$(1)))))))

# -----------------------------------------------------------------------------

GOLANG_BUILD_OPTS = \
	-ldflags "$(strip $($(PKG)_LDFLAGS) $(if $(strip $(GOLANG_EXTLDFLAGS)),-extldflags '$(strip $(GOLANG_EXTLDFLAGS))'))" \
	-modcacherw \
	-tags "$(strip $($(PKG)_TAGS))" \
	-trimpath \
	-p $(PARALLEL_JOBS) \
	-buildvcs=false

GOLANG_EXTLDFLAGS = \
	$($(PKG)_EXTLDFLAGS) \
	$(if $(filter $(PKG_DESTINATION),TARGET),$(TARGET_GOLANG_EXTLDFLAGS))

GOLANG_CGO_ENV = \
	CGO_ENABLED=$(if $(filter $($(PKG)_GO_CGO),YES),1,0)

# Go forces use of the Gold linker on aarch64 due to a bug in BFD that
# is fixed in Binutils >= 2.41. Forcing Gold will break with toolchains
# that don't provide it, so override the flag and use BFD.
# See: https://github.com/golang/go/issues/22040
ifeq ($(TARGET_ARCH),aarch64)
  TARGET_GOLANG_EXTLDFLAGS += -fuse-ld=bfd
endif

# -----------------------------------------------------------------------------

# Generate a go.mod file if it doesn't exist and vendor all dependencies.
# This is the only step where Go is allowed to make network calls; the
# build itself uses the "vendor" directory only.
define GOLANG_CONFIGURE_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		if [ ! -f go.mod ]; then \
			printf "module %s\n" "$($(PKG)_GOMOD)" > go.mod; \
		fi; \
		if [ ! -d vendor ]; then \
			$(HOST_GO_COMMON_ENV) \
			GOFLAGS=-mod=mod \
			GOPROXY="$(BS_GOPROXY)" \
			$($(PKG)_GO_ENV) \
			$(HOST_GO_BINARY) mod vendor $(if $(VERBOSE),-v) -modcacherw; \
		fi
endef

define GOLANG_CONFIGURE
	@$(call MESSAGE,"Configuring $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_CONFIGURE_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_CONFIGURE_CMDS)
	$(foreach hook,$($(PKG)_POST_CONFIGURE_HOOKS),$(call $(hook))$(sep))
endef

define GOLANG_BUILD
	@$(call MESSAGE,"Building $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_BUILD_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_BUILD_CMDS)
	$(foreach hook,$($(PKG)_POST_BUILD_HOOKS),$(call $(hook))$(sep))
endef

define GOLANG_INSTALL
	@$(call MESSAGE,"Installing $(pkgname)")
	$(foreach hook,$($(PKG)_PRE_INSTALL_HOOKS),$(call $(hook))$(sep))
	$(Q)$(call $(PKG)_INSTALL_CMDS)
	$(foreach hook,$($(PKG)_POST_INSTALL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

# If the build target is just ".", the binary is named after the package.
# Otherwise each binary is named after the build target building it.
define TARGET_GOLANG_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(foreach d,$($(PKG)_BUILD_TARGETS),\
		$(HOST_GO_TARGET_ENV) $(GOLANG_CGO_ENV) $($(PKG)_GO_ENV) \
		$(HOST_GO_BINARY) build $(if $(VERBOSE),-v) \
			$(GOLANG_BUILD_OPTS) $($(PKG)_BUILD_OPTS) \
			-o $(PKG_BUILD_DIR)/bin/$(or $($(PKG)_BIN_NAME),$(notdir $(d))) \
			./$(d);)
endef

define TARGET_GOLANG_INSTALL_CMDS_DEFAULT
	$(foreach d,$($(PKG)_INSTALL_BINS),\
		$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/bin/$(d) $(TARGET_bindir)/$(d);)
endef

define golang-package
	$(eval PKG_MODE = $(pkg-mode))
	$(if $(filter $(GO_TARGET_ARCH_SUPPORTS),YES),,\
		$(error $(pkgname): Go packages are not supported on $(BOXMODEL) ($(TARGET_ARCH)/$(TARGET_CPU), kernel $(KERNEL_VERSION))))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call GOLANG_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call GOLANG_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call GOLANG_INSTALL))
	$(call FOLLOWUP,$(1))
endef

# -----------------------------------------------------------------------------

define HOST_GOLANG_BUILD_CMDS_DEFAULT
	$(CD) $(PKG_BUILD_DIR); \
		$(foreach d,$($(PKG)_BUILD_TARGETS),\
		$(HOST_GO_HOST_ENV) $(GOLANG_CGO_ENV) $($(PKG)_GO_ENV) \
		$(HOST_GO_BINARY) build $(if $(VERBOSE),-v) \
			$(GOLANG_BUILD_OPTS) $($(PKG)_BUILD_OPTS) \
			-o $(PKG_BUILD_DIR)/bin/$(or $($(PKG)_BIN_NAME),$(notdir $(d))) \
			./$(d);)
endef

define HOST_GOLANG_INSTALL_CMDS_DEFAULT
	$(foreach d,$($(PKG)_INSTALL_BINS),\
		$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/bin/$(d) $(HOST_DIR)/bin/$(d);)
endef

define host-golang-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_CONFIGURE)),,$(call GOLANG_CONFIGURE))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call GOLANG_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call GOLANG_INSTALL))
	$(call FOLLOWUP,$(1))
endef
