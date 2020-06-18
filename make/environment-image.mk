#
# set up image environment for other makefiles
#
# -----------------------------------------------------------------------------

# Versioning
GITTAG=$(shell git tag -l "NI-*" | tail -n1)
GITREV=$(shell git rev-list $(GITTAG)..HEAD --count)

IMAGE_VER_MAJOR = 3
IMAGE_VER_MINOR = 60
IMAGE_VER_MICRO = $(GITREV)
IMAGE_VER = $(IMAGE_VER_MAJOR)$(IMAGE_VER_MINOR)

IMAGE_VERSION = $(IMAGE_VER_MAJOR).$(IMAGE_VER_MINOR).$(IMAGE_VER_MICRO)

# Release date
IMAGE_DATE = $(shell date +%Y%m%d%H%M)

# Image names
IMAGE_PREFIX = ni$(IMAGE_VER)-$(IMAGE_DATE)
IMAGE_SUFFIX = $(BOXTYPE_SC)-$(BOXMODEL)

IMAGE_NAME   = $(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
IMAGE_TYPE  ?= 9
# Release    = 0
# Beta       = 1
# Nightly    = 2
# Selfmade   = 9

# JFFS2-Summary
IMAGE_SUMMARIZE = yes

# newimage-flag
IMAGE_NEW = no

# Beta/Release Server
NI-SERVER = http://neutrino-images.de/neutrino-images
ifeq ($(IMAGE_TYPE), 0)
  # Release
  NI-SUBDIR = release
  IMAGE_TYPE_STRING = release
else ifeq ($(IMAGE_TYPE), 1)
  # Beta
  NI-SUBDIR = beta
  IMAGE_TYPE_STRING = beta
else ifeq ($(IMAGE_TYPE), 2)
  # Nightly
  NI-SUBDIR = nightly
  IMAGE_TYPE_STRING = nightly
else
  # Selfmade; just for compatibility; not needed for our builds
  NI-SUBDIR = selfmade
  IMAGE_TYPE_STRING = selfmade
endif

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), coolstream))
  IMAGE_DESC ="$(BOXNAME) [$(IMAGE_SUFFIX)][$(BOXSERIES)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
else
  IMAGE_DESC ="$(BOXNAME) [$(IMAGE_SUFFIX)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
endif

IMAGE_SITE = $(NI-SERVER)/$(NI-SUBDIR)
IMAGE_MD5FILE = $(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt

IMAGE_BUILD_TMP = $(BUILD_TMP)/image-build

ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
  IMAGE_SUBDIR = $(subst vu,vuplus/,$(BOXMODEL))
else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), h7))
  IMAGE_SUBDIR = zgemma/$(BOXMODEL)
else
  IMAGE_SUBDIR = $(BOXMODEL)
endif
