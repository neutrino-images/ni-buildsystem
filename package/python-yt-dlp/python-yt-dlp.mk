################################################################################
#
# python-yt-dlp
#
################################################################################

PYTHON_YT_DLP_VERSION = 2023.12.30
PYTHON_YT_DLP_DIR = yt-dlp-$(PYTHON_YT_DLP_VERSION)
PYTHON_YT_DLP_SOURCE = yt-dlp-$(PYTHON_YT_DLP_VERSION).tar.gz
PYTHON_YT_DLP_SITE = https://files.pythonhosted.org/packages/source/y/yt-dlp

PYTHON_YT_DLP_DEPENDENCIES = python3 python-brotli python-certifi python-websockets \
	python-requests python-mutagen python-pycryptodomex

PYTHON_YT_DLP_SETUP_TYPE = setuptools

define PYTHON_YT_DLP_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_docdir)
	$(TARGET_RM) $(TARGET_mandir)
	$(TARGET_RM) $(TARGET_datarootdir)/fish
	$(TARGET_RM) $(TARGET_datarootdir)/zsh
endef
PYTHON_YT_DLP_TARGET_FINALIZE_HOOKS += PYTHON_YT_DLP_TARGET_CLEANUP

python-yt-dlp: | $(TARGET_DIR)
	$(call python-package)
