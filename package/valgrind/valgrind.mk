################################################################################
#
# valgrind
#
################################################################################

VALGRIND_VERSION = 3.18.1
VALGRIND_DIR = valgrind-$(VALGRIND_VERSION)
VALGRIND_SOURCE = valgrind-$(VALGRIND_VERSION).tar.bz2
VALGRIND_SITE = ftp://sourceware.org/pub/valgrind

VALGRIND_AUTORECONF = YES

VALGRIND_CONF_OPTS = \
	--enable-only32bit \
	--datadir=$(REMOVE_datadir)

define VALGRIND_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/valgrind/,*.a)
	$(TARGET_RM) $(addprefix $(TARGET_libexecdir)/valgrind/,*)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,cg_* callgrind_* ms_print valgrind-* vgdb)
endef
VALGRIND_TARGET_FINALIZE_HOOKS += VALGRIND_TARGET_CLEANUP

valgrind: | $(TARGET_DIR)
	$(call autotools-package)
