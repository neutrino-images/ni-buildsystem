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

host-waf: | $(HOST_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(INSTALL_EXEC) -D waf $(HOST_WAF_BINARY)
	$(call HOST_FOLLOWUP)
