# clean all for rebuild (except the toolchain)

rebuild-clean:
	-rm -rf $(BUILD_TMP)
	-rm -rf $(TARGETPREFIX)
	-rm -rf $(D)

staging-clean:
	-rm -rf $(STAGING_DIR)

static-clean:
	-rm -rf $(STATIC_DIR)

all-clean: rebuild-clean staging-clean static-clean
	@echo -e "\n\033[40;0;33mAny other key then CTRL-C will now remove CROSS_BASE and HOSTPREFIX\033[0m"
	@read
	-rm -rf $(CROSS_BASE)
	-rm -rf $(HOSTPREFIX)

%-clean:
	cd $(D) && find . -name $(subst -clean,,$@) -delete

ni-clean \
clean: rebuild-clean pkg-clean bootstrap

clean-all:
	make update-all
	make staging-clean
	make clean

PHONY += rebuild-clean all-clean pkg-clean
