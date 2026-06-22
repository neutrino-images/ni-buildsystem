################################################################################
#
# ne
#
################################################################################

NE_VERSION = 3.3.4
NE_DIR = ne-$(NE_VERSION)
NE_SOURCE = ne-$(NE_VERSION).tar.gz
NE_SITE = $(call github,vigna,ne,refs/tags/$(NE_VERSION))

NE_DEPENDENCIES = ncurses

# suppress annoying warnings: @noindent is useless inside of a paragraph
define NE_PATCH_MAKEFILE
	$(SED) "s/makeinfo/makeinfo --no-warn/g" $(PKG_BUILD_DIR)/doc/makefile
	$(SED) "s/makeinfo/makeinfo --no-warn/g" $(PKG_BUILD_DIR)/src/makefile
endef
NE_POST_PATCH_HOOKS += NE_PATCH_MAKEFILE

NE_MAKE = $(MAKE1)

NE_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	PREFIX=$(prefix)

define NE_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_docdir)
	$(TARGET_RM) $(TARGET_infodir)
	$(TARGET_RM) $(TARGET_mandir)
endef
NE_TARGET_FINALIZE_HOOKS += NE_TARGET_CLEANUP

ne: | $(TARGET_DIR)
	$(call generic-package)
