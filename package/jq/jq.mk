################################################################################
#
# jq
#
################################################################################

JQ_VERSION = master
JQ_DIR = jq.git
JQ_SOURCE = jq.git
JQ_SITE = https://github.com/stedolan
JQ_SITE_METHOD = git

JQ_DEPENDENCIES = oniguruma

JQ_AUTORECONF = YES

JQ_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir)

jq: | $(TARGET_DIR)
	$(call autotools-package)
