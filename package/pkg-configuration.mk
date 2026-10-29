################################################################################
#
# This file contains various configurations used by the packages.
# Configuration keys may be overridden in config.local
#
################################################################################

# ffmpeg2: branch
BS_PACKAGE_FFMPEG2_BRANCH ?= ni/ffmpeg/2.8
#BS_PACKAGE_FFMPEG2_BRANCH ?= ni/ffmpeg/master
#BS_PACKAGE_FFMPEG2_BRANCH ?= ffmpeg/master

# ffmpeg: build ffplay
BS_PACKAGE_FFMPEG_FFPLAY ?= n

# ffmpeg: build ffprobe (needed by yt-dlp)
BS_PACKAGE_FFMPEG_FFPROBE ?= y

# ncurses: build wide-character libraries
BS_PACKAGE_NCURSES_WCHAR ?= y

# libstb-hal: branch
BS_PACKAGE_LIBSTB_HAL_BRANCH ?=
ifeq ($(BS_PACKAGE_LIBSTB_HAL_BRANCH),$(empty))
BS_PACKAGE_LIBSTB_HAL_BRANCH = master
endif

# neutrino: branch
BS_PACKAGE_NEUTRINO_BRANCH ?=
ifeq ($(BS_PACKAGE_NEUTRINO_BRANCH),$(empty))
BS_PACKAGE_NEUTRINO_BRANCH = master
endif

# neutrino: use ffmpeg audio decoder
BS_PACKAGE_NEUTRINO_AUDIODEC_FFMPEG ?= y

# neutrino: use pip
BS_PACKAGE_NEUTRINO_PIP ?= y

# neutrino: use softcsa
BS_PACKAGE_NEUTRINO_SOFTCSA ?= y

# boxes with no room in the root filesystem for the web interface extras
NI_SHORT_OF_FLASH = nevis

NI_TIGHT = $(if $(filter $(BOXMODEL),$(NI_SHORT_OF_FLASH)),y,n)

# neutrino: ship the swagger-ui docs page and the descriptions it reads
ifeq ($(NI_TIGHT),y)
  BS_PACKAGE_NEUTRINO_API_DOC ?= n
else
  BS_PACKAGE_NEUTRINO_API_DOC ?= y
endif

# neutrino: ship the libraries a browser needs to play what the box sends
ifeq ($(NI_TIGHT),y)
  BS_PACKAGE_NEUTRINO_WEB_PLAYER ?= n
else
  BS_PACKAGE_NEUTRINO_WEB_PLAYER ?= y
endif

# neutrino: ship the new web interface
BS_PACKAGE_NEUTRINO_NI_WEB ?= y

# neutrino: let AI clients reach the box over MCP with OAuth
ifeq ($(NI_TIGHT),y)
  BS_PACKAGE_NEUTRINO_MCP ?= n
else
  BS_PACKAGE_NEUTRINO_MCP ?= y
endif

# neutrino: omdb api key
BS_PACKAGE_NEUTRINO_OMDB_API_KEY ?=
ifeq ($(BS_PACKAGE_NEUTRINO_OMDB_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_OMDB_API_KEY = 20711f9e
endif

# neutrino: tmdb api key
BS_PACKAGE_NEUTRINO_TMDB_API_KEY ?=
ifeq ($(BS_PACKAGE_NEUTRINO_TMDB_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_TMDB_API_KEY = 7270f1b571c4ecbb5b204ddb7f8939b1
endif

# neutrino: shoutcast developer id
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID ?=
ifeq ($(BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID),$(empty))
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID = fa1669MuiRPorUBw
endif

# neutrino: youtube api key
BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY ?=
ifeq ($(BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY = AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM
endif

# neutrino: weather api key; no default key available
BS_PACKAGE_NEUTRINO_WEATHER_API_KEY ?=

# vu+ drivers: use latest version
BS_PACKAGE_VUPLUS_DRIVERS_LATEST ?= n

# -----------------------------------------------------------------------------

# image: add own packages
BS_PACKAGES_OWN ?=
