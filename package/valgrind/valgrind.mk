################################################################################
#
# valgrind
#
################################################################################

VALGRIND_VERSION = 3.13.0
VALGRIND_DIR = valgrind-$(VALGRIND_VERSION)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VERSION).tar.bz2
VALGRIND_SITE = ftp://sourceware.org/pub/valgrind

$(DL_DIR)/$(VALGRIND_SOURCE):
	$(download) $(VALGRIND_SITE)/$(VALGRIND_SOURCE)

VALGRIND_PATCH  = valgrind-fix-build-$(TARGET_CPU).patch

VALGRIND_AUTORECONF = YES

VALGRIND_CONF_OPTS = \
	--enable-only32bit \
	--datadir=$(REMOVE_datadir)

valgrind: $(DL_DIR)/$(VALGRIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCH))
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/valgrind/,*.a *.xml)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,cg_* callgrind_* ms_print)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
