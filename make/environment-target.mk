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

modulesdir		= $(base_libdir)/modules/$(KERNEL_VERSION)

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
man1dir			= $(mandir)/man1
man2dir			= $(mandir)/man2

# -----------------------------------------------------------------------------

dir_VARIABLES = prefix \
		exec_prefix \
		base_bindir \
		base_sbindir \
		base_datarootdir \
		base_datadir \
		base_includedir \
		base_libdir \
		modulesdir \
		bindir \
		sbindir \
		libexecdir \
		datarootdir \
		datadir \
		sysconfdir \
		sharedstatedir \
		localstatedir \
		runstatedir \
		includedir \
		oldincludedir \
		docdir \
		infodir \
		htmldir \
		dvidir \
		pdfdir \
		psdir \
		libdir \
		lispdir \
		localedir \
		mandir \
		man1dir \
		man2dir

# -----------------------------------------------------------------------------

TARGET_DIR ?= $(BASE_DIR)/root

# auto-set TARGET_ directories
$(foreach dir,$(dir_VARIABLES),$(eval TARGET_$(dir) = $(TARGET_DIR)$($(dir))))

# -----------------------------------------------------------------------------

REMOVE_DIR = /.remove

# auto-set REMOVE_ directories
$(foreach dir,$(dir_VARIABLES),$(eval REMOVE_$(dir) = $(REMOVE_DIR)$($(dir))))

# -----------------------------------------------------------------------------

PERSISTENT_VAR_PARTITION = $(if $(filter $(BOXMODEL),apollo shiner kronos kronos_v2),yes,no)
