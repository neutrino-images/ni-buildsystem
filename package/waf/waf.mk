################################################################################
#
# waf
#
################################################################################

WAF_VERSION = 2.0.24
WAF_DIR = waf-$(WAF_VERSION)
WAF_SOURCE = waf-$(WAF_VERSION).tar.bz2
WAF_SITE = https://waf.io

# ------------------------------------------------------------------------------

HOST_WAF_VERSION = $(WAF_VERSION)
HOST_WAF_DIR = $(WAF_DIR)
HOST_WAF_SOURCE = $(WAF_SOURCE)
HOST_WAF_SITE = $(WAF_SITE)

HOST_WAF_BINARY = $(HOST_DIR)/bin/waf

define HOST_WAF_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/waf $(HOST_WAF_BINARY)
endef
HOST_WAF_INDIVIDUAL_HOOKS += HOST_WAF_INSTALL_BINARY

host-waf: | $(HOST_DIR)
	$(call host-individual-package)
