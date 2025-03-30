################################################################################
#
# python-yt-dlp
#
################################################################################

PYTHON_YT_DLP_VERSION = 2025.3.27
PYTHON_YT_DLP_DIR = yt_dlp-$(PYTHON_YT_DLP_VERSION)
PYTHON_YT_DLP_SOURCE = yt_dlp-$(PYTHON_YT_DLP_VERSION).tar.gz
PYTHON_YT_DLP_SITE = $(PYPI_MIRROR)/y/yt-dlp

PYTHON_YT_DLP_DEPENDENCIES = python-brotli python-certifi python-websockets \
	python-requests python-mutagen python-pycryptodomex

#PYTHON_YT_DLP_SETUP_TYPE = setuptools
PYTHON_YT_DLP_SETUP_TYPE = flit

define PYTHON_YT_DLP_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_docdir) $(TARGET_mandir)
	$(TARGET_RM) $(addprefix $(TARGET_datarootdir)/,fish zsh)
endef
PYTHON_YT_DLP_TARGET_FINALIZE_HOOKS += PYTHON_YT_DLP_TARGET_CLEANUP

python-yt-dlp: | $(TARGET_DIR)
	$(call python-package)
