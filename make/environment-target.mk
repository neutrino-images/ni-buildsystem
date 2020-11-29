#
# set up target environment for other makefiles
#
# -----------------------------------------------------------------------------

# Path prefixes
base_prefix		=
prefix			= /usr
exec_prefix		= $(prefix)

# Base paths
base_bindir		= $(base_prefix)/bin
base_sbindir		= $(base_prefix)/sbin
base_datarootdir	= $(base_prefix)/share
base_datadir		= $(base_datarootdir)
base_includedir		= $(base_prefix)/include
base_libdir		= $(base_prefix)/lib

modulesdir		= $(base_libdir)/modules

# -----------------------------------------------------------------------------

# https://www.gnu.org/prep/standards/html_node/Directory-Variables.html

bindir			= $(exec_prefix)/bin
sbindir			= $(exec_prefix)/sbin
libexecdir		= $(exec_prefix)/libexec
datarootdir		= $(prefix)/share
datadir			= $(datarootdir)
sysconfdir		= $(base_prefix)/etc
sharedstatedir		= $(base_prefix)/com
localstatedir		= $(base_prefix)/var
runstatedir		= $(localstatedir)/run
includedir		= $(exec_prefix)/include
oldincludedir		= $(exec_prefix)/include
docdir			= $(datadir)/doc
infodir			= $(datadir)/info
htmldir			= $(docdir)
dvidir			= $(docdir)
pdfdir			= $(docdir)
psdir			= $(docdir)
libdir			= $(exec_prefix)/lib
lispdir			= $(datarootdir)/emacs/site-lisp
localedir		= $(datarootdir)/locale
mandir			= $(datadir)/man
mandir1			= $(mandir)/man1
mandir2			= $(mandir)/man2

# -----------------------------------------------------------------------------

REMOVE_dir		= /.remove
REMOVE_bindir		= $(REMOVE_dir)/bin
REMOVE_sbindir		= $(REMOVE_dir)/sbin
REMOVE_libexecdir	= $(REMOVE_dir)/libexec
REMOVE_datarootdir	= $(REMOVE_dir)/share
REMOVE_datadir		= $(REMOVE_datarootdir)
REMOVE_sysconfdir	= $(REMOVE_dir)/etc
REMOVE_sharedstatedir	= $(REMOVE_dir)/com
REMOVE_localstatedir	= $(REMOVE_dir)/var
REMOVE_runstatedir	= $(REMOVE_localstatedir)/run
REMOVE_includedir	= $(REMOVE_dir)/include
REMOVE_oldincludedir	= $(REMOVE_includedir)
REMOVE_docdir		= $(REMOVE_datarootdir)/doc
REMOVE_infodir		= $(REMOVE_datarootdir)/info
REMOVE_htmldir		= $(REMOVE_docdir)
REMOVE_dvidir		= $(REMOVE_docdir)
REMOVE_pdfdir		= $(REMOVE_docdir)
REMOVE_psdir		= $(REMOVE_docdir)
REMOVE_libdir		= $(REMOVE_dir)/lib
REMOVE_lispdir		= $(REMOVE_datarootdir)/emacs/site-lisp
REMOVE_localedir	= $(REMOVE_datarootdir)/locale
REMOVE_mandir		= $(REMOVE_datarootdir)/man
REMOVE_man1dir		= $(REMOVE_mandir)/man1
REMOVE_man2dir		= $(REMOVE_mandir)/man2

# -----------------------------------------------------------------------------

TARGET_prefix		= $(TARGET_DIR)$(prefix)
TARGET_exec_prefix	= $(TARGET_DIR)$(exec_prefix)

TARGET_base_bindir	= $(TARGET_DIR)$(base_bindir)
TARGET_base_sbindir	= $(TARGET_DIR)$(base_sbindir)
TARGET_base_includedir	= $(TARGET_DIR)$(base_includedir)
TARGET_base_libdir	= $(TARGET_DIR)$(base_libdir)

TARGET_modulesdir	= $(TARGET_base_libdir)/modules/$(KERNEL_VER)

TARGET_bindir		= $(TARGET_DIR)$(bindir)
TARGET_sbindir		= $(TARGET_DIR)$(sbindir)
TARGET_libdir		= $(TARGET_DIR)$(libdir)
TARGET_datadir		= $(TARGET_DIR)$(datadir)
TARGET_sysconfdir	= $(TARGET_DIR)$(sysconfdir)
TARGET_includedir	= $(TARGET_DIR)$(includedir)
TARGET_localstatedir	= $(TARGET_DIR)$(localstatedir)

# -----------------------------------------------------------------------------

SHARE_FLEX	= $(TARGET_datadir)/tuxbox/neutrino/flex
SHARE_ICONS	= $(TARGET_datadir)/tuxbox/neutrino/icons
SHARE_LOGOS	= $(TARGET_datadir)/tuxbox/neutrino/icons/logo
SHARE_PLUGINS	= $(TARGET_datadir)/tuxbox/neutrino/plugins
SHARE_THEMES	= $(TARGET_datadir)/tuxbox/neutrino/themes
SHARE_WEBRADIO	= $(TARGET_datadir)/tuxbox/neutrino/webradio
SHARE_WEBTV	= $(TARGET_datadir)/tuxbox/neutrino/webtv
VAR_CONFIG	= $(TARGET_localstatedir)/tuxbox/config
VAR_PLUGINS	= $(TARGET_localstatedir)/tuxbox/plugins

$(SHARE_FLEX) \
$(SHARE_ICONS) \
$(SHARE_LOGOS) \
$(SHARE_PLUGINS) \
$(SHARE_THEMES) \
$(SHARE_WEBRADIO) \
$(SHARE_WEBTV) \
$(VAR_CONFIG) \
$(VAR_PLUGINS) : | $(TARGET_DIR)
	mkdir -p $(@)

# -----------------------------------------------------------------------------

PERSISTENT_VAR_PARTITION = $(if $(filter $(BOXMODEL), apollo shiner kronos kronos_v2),yes,no)
