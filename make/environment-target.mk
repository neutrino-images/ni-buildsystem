#
# set up target environment for other makefiles
#
# -----------------------------------------------------------------------------

BIN		= $(TARGET_DIR)/bin
ETCINITD	= $(TARGET_DIR)/etc/init.d
SBIN		= $(TARGET_DIR)/sbin
SHAREFLEX	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/flex
SHAREICONS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/icons
SHAREPLUGINS	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/plugins
SHARETHEMES	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/themes
SHAREWEBRADIO	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webradio
SHAREWEBTV	= $(TARGET_SHARE_DIR)/tuxbox/neutrino/webtv
VARCONFIG	= $(TARGET_DIR)/var/tuxbox/config
VARINITD	= $(TARGET_DIR)/var/etc/init.d
VARPLUGINS	= $(TARGET_DIR)/var/tuxbox/plugins

$(ETCINITD) \
$(SBIN) \
$(SHAREFLEX) \
$(SHAREICONS) \
$(SHAREPLUGINS) \
$(SHARETHEMES) \
$(SHAREWEBRADIO) \
$(SHAREWEBTV) \
$(VARCONFIG) \
$(VARINITD) \
$(VARPLUGINS) : | $(TARGET_DIR)
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

PERSISTENT_VAR_PARTITION = $(if $(filter $(BOXMODEL), apollo shiner kronos kronos_v2), yes, no)
