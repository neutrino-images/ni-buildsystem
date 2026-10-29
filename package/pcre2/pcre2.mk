################################################################################
#
# pcre2
#
################################################################################

PCRE2_VERSION = 10.49
PCRE2_DIR = pcre2-$(PCRE2_VERSION)
PCRE2_SOURCE = pcre2-$(PCRE2_VERSION).tar.bz2
PCRE2_SITE = https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$(PCRE2_VERSION)

PCRE2_CONFIG_SCRIPTS = pcre2-config

# Fixes build/relink failure ("ERROR: unsafe header/library path used in
# cross-compilation: '-L/usr/lib'")
PCRE2_AUTORECONF = YES

PCRE2_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	$(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared) \
	--enable-pcre2-8 \
	--disable-pcre2-16 \
	--disable-pcre2-32 \
	--disable-jit

define PCRE2_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,pcre2grep pcre2test)
endef
PCRE2_TARGET_FINALIZE_HOOKS += PCRE2_TARGET_CLEANUP

pcre2: | $(TARGET_DIR)
	$(call autotools-package)
