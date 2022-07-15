#
# set up image environment for other makefiles
#
# -----------------------------------------------------------------------------

# Debug image
DEBUG ?= no

# Versioning
GITTAG = $(shell git tag -l "NI-*" | tail -n1)
GITREV = $(shell git rev-list $(GITTAG)..HEAD --count)

# *Must* be a one-digit number
IMAGE_VERSION_MAJOR = 4
# *Must* be a two-digit number
IMAGE_VERSION_MINOR = 20
IMAGE_VERSION_MICRO = $(GITREV)
IMAGE_VERSION_DOY = $(shell date +%j)

IMAGE_VERSION = $(IMAGE_VERSION_MAJOR).$(IMAGE_VERSION_MINOR).$(IMAGE_VERSION_MICRO).$(IMAGE_VERSION_DOY)

# Release date
IMAGE_DATE = $(shell date +%Y%m%d%H%M)

# Image names
IMAGE_PREFIX = ni$(IMAGE_VERSION_MAJOR)$(IMAGE_VERSION_MINOR)-$(IMAGE_DATE)
IMAGE_SUFFIX = $(BOXTYPE_SC)-$(BOXMODEL)
IMAGE_NAME   = $(IMAGE_PREFIX)-$(IMAGE_SUFFIX)

# Image type
IMAGE_TYPE  ?= 9
# Release    = 0
# Beta       = 1
# Nightly    = 2
# Selfmade   = 9

IMAGE_VERSION_STRING = $(IMAGE_TYPE)$(IMAGE_VERSION_MAJOR)$(IMAGE_VERSION_MINOR)$(IMAGE_DATE)

# JFFS2-Summary
IMAGE_SUMMARIZE = yes

# newimage-flag
IMAGE_NEW = no

# Beta/Release Server
NI_SERVER = http://neutrino-images.de/neutrino-images
ifeq ($(IMAGE_TYPE),0)
  # Release
  NI_SUBDIR = release
  IMAGE_TYPE_STRING = release
else ifeq ($(IMAGE_TYPE),1)
  # Beta
  NI_SUBDIR = beta
  IMAGE_TYPE_STRING = beta
else ifeq ($(IMAGE_TYPE),2)
  # Nightly
  NI_SUBDIR = nightly
  IMAGE_TYPE_STRING = nightly
else
  # Selfmade; just for compatibility; not needed for our builds
  NI_SUBDIR = selfmade
  IMAGE_TYPE_STRING = selfmade
endif

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))
  IMAGE_DESC ="$(BOXNAME) [$(IMAGE_SUFFIX)][$(BOXSERIES)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
else
  IMAGE_DESC ="$(BOXNAME) [$(IMAGE_SUFFIX)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
endif

IMAGE_SITE = $(NI_SERVER)/$(NI_SUBDIR)
IMAGE_MD5FILE = $(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt

IMAGE_BUILD_DIR = $(BUILD_DIR)/image-build

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
  IMAGE_SUBDIR = $(subst vu,vuplus/,$(BOXMODEL))
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),h7))
  IMAGE_SUBDIR = zgemma/$(BOXMODEL)
else
  IMAGE_SUBDIR = $(BOXMODEL)
endif
