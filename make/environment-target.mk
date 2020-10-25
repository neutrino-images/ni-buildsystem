#
# set up target environment for other makefiles
#
# -----------------------------------------------------------------------------

SHARE_FLEX	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/flex
SHARE_ICONS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons
SHARE_LOGOS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons/logo
SHARE_PLUGINS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
SHARE_THEMES	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/themes
SHARE_WEBRADIO	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webradio
SHARE_WEBTV	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
VAR_CONFIG	= $(TARGET_DIR)/var/tuxbox/config
VAR_PLUGINS	= $(TARGET_DIR)/var/tuxbox/plugins

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

# https://www.gnu.org/prep/standards/html_node/Directory-Variables.html
remove-dir		= /.remove
remove-bindir		= $(remove-dir)/bin
remove-sbindir		= $(remove-dir)/sbin
remove-libexecdir	= $(remove-dir)/libexec
remove-datarootdir	= $(remove-dir)/share
remove-datadir		= $(remove-datarootdir)
remove-sysconfdir	= $(remove-dir)/etc
remove-sharedstatedir	= $(remove-dir)/com
remove-localstatedir	= $(remove-dir)/var
remove-runstatedir	= $(remove-dir)/run
remove-includedir	= $(remove-dir)/include
remove-oldincludedir	= $(remove-includedir)
remove-docdir		= $(remove-datarootdir)/doc
remove-infodir		= $(remove-datarootdir)/info
remove-htmldir		= $(remove-docdir)
remove-dvidir		= $(remove-docdir)
remove-pdfdir		= $(remove-docdir)
remove-psdir		= $(remove-docdir)
remove-libdir		= $(remove-dir)/lib
remove-lispdir		= $(remove-datarootdir)/emacs/site-lisp
remove-localedir	= $(remove-datarootdir)/locale
remove-mandir		= $(remove-datarootdir)/man
remove-man1dir		= $(remove-mandir)/man1
remove-man2dir		= $(remove-mandir)/man2

# -----------------------------------------------------------------------------

# ca-certificates
CA-BUNDLE	= ca-certificates.crt
CA-BUNDLE_DIR	= /etc/ssl/certs

# -----------------------------------------------------------------------------

PERSISTENT_VAR_PARTITION = $(if $(filter $(BOXMODEL), apollo shiner kronos kronos_v2),yes,no)
