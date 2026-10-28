################################################################################
#
# yq
#
################################################################################

YQ_VERSION = 4.49.2
YQ_DIR = yq-$(YQ_VERSION)
YQ_SOURCE =yq-$(YQ_VERSION).tar.gz
YQ_SITE = $(call github,mikefarah,yq,v$(YQ_VERSION))
YQ_GOMOD = github.com/mikefarah/yq/v4

yq: | $(TARGET_DIR)
	$(call golang-package)
