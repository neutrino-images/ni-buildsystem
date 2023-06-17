################################################################################
#
# ccache
#
################################################################################

ifndef CCACHE
CCACHE := ccache
endif
CCACHE := $(shell which $(CCACHE) || type -p $(CCACHE) || echo ccache)

CCACHE_DIR = $(HOME)/.ccache-$(call LOWERCASE,$(TARGET_VENDOR))-$(TARGET_ARCH)-$(TARGET_OS)-$(KERNEL_VERSION)
export CCACHE_DIR

# ------------------------------------------------------------------------------

HOST_CCACHE_BINDIR = $(HOST_DIR)/bin

$(HOST_CCACHE_BINDIR): | $(HOST_DIR)
	$(INSTALL) -d $(@)

HOST_CCACHE_HOST_LINKS = \
	$(HOST_CCACHE_BINDIR)/cc \
	$(HOST_CCACHE_BINDIR)/gcc \
	$(HOST_CCACHE_BINDIR)/cpp \
	$(HOST_CCACHE_BINDIR)/g++

HOST_CCACHE_TARGET_LINKS = \
	$(HOST_CCACHE_BINDIR)/$(GNU_TARGET_NAME)-gcc \
	$(HOST_CCACHE_BINDIR)/$(GNU_TARGET_NAME)-cpp \
	$(HOST_CCACHE_BINDIR)/$(GNU_TARGET_NAME)-g++

$(HOST_CCACHE_HOST_LINKS) \
$(HOST_CCACHE_TARGET_LINKS): | $(HOST_CCACHE_BINDIR)
	ln -sf $(CCACHE) $(@)

HOST_CCACHE_DEPENDENCIES = find-ccache $(CCACHE) \
	$(HOST_CCACHE_HOST_LINKS) \
	$(HOST_CCACHE_TARGET_LINKS)

host-ccache: | $(HOST_DIR)
	$(call host-virtual-package)
