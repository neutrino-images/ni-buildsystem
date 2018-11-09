#
# set up image environment for other makefiles
#
# -----------------------------------------------------------------------------

# Release date
IMAGE_DATE	= $(shell date +%Y%m%d%H%M)

# Version Strings
IMAGE_VERSION	= 360
IMAGE_PREFIX	= ni$(IMAGE_VERSION)-$(IMAGE_DATE)
IMAGE_SUFFIX	= $(BOXTYPE_SC)-$(BOXMODEL)

# Image-Type
# Release	= 0
# Beta		= 1
# Nightly	= 2
# Selfmade	= 9
IMAGE_TYPE	?= 9

# JFFS2-Summary
IMAGE_SUMMARIZE	= yes

# newimage-flag
IMAGE_NEW	= no

# Beta/Release Server
NI-SERVER	= http://neutrino-images.de/neutrino-images
ifeq ($(IMAGE_TYPE), 0)
  # Release
  NI-SUBDIR	= release
  IMAGE_TYPE_STRING = release
else ifeq ($(IMAGE_TYPE), 1)
  # Beta
  NI-SUBDIR	= beta
  IMAGE_TYPE_STRING = beta
else ifeq ($(IMAGE_TYPE), 2)
  # Nightly
  NI-SUBDIR	= nightly
  IMAGE_TYPE_STRING = nightly
else
  # Selfmade; just for compatibility; not needed for our builds
  NI-SUBDIR	= selfmade
  IMAGE_TYPE_STRING = selfmade
endif

IMAGE_URL = $(NI-SERVER)/$(NI-SUBDIR)
IMAGE_VERSION_STRING = $(shell echo $(IMAGE_VERSION) | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{2\}\)/\1.\2/;ta')
