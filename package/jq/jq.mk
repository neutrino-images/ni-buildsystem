################################################################################
#
# jq
#
################################################################################

JQ_VERSION = git
JQ_DIR = jq.$(JQ_VERSION)
JQ_SOURCE = jq.$(JQ_VERSION)
JQ_SITE = https://github.com/stedolan

JQ_DEPENDENCIES = oniguruma

JQ_AUTORECONF = YES

JQ_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir)

jq: | $(TARGET_DIR)
	$(call autotools-package)
