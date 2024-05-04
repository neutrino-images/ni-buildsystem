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

# ffmpeg4: build ffplay
BS_PACKAGE_FFMPEG4_FFPLAY ?= n

# ffmpeg4: build ffprobe (needed by yt-dlp)
BS_PACKAGE_FFMPEG4_FFPROBE ?= y

# ncurses: build wide-character libraries
BS_PACKAGE_NCURSES_WCHAR ?= y

# neutrino: branch
BS_PACKAGE_NEUTRINO_BRANCH ?= $(NEUTRINO_BRANCH)
ifeq ($(BS_PACKAGE_NEUTRINO_BRANCH),$(empty))
BS_PACKAGE_NEUTRINO_BRANCH = master
endif

# neutrino: use ffmpeg audio decoder
BS_PACKAGE_NEUTRINO_AUDIODEC_FFMPEG ?= y

# neutrino: use pip
BS_PACKAGE_NEUTRINO_PIP ?= y

# neutrino: omdb api key
# backwards compatibility will be removed soon
BS_PACKAGE_NEUTRINO_OMDB_API_KEY ?= $(NEUTRINO_OMDB_API_KEY)
ifeq ($(BS_PACKAGE_NEUTRINO_OMDB_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_OMDB_API_KEY = 20711f9e
endif

# neutrino: tmdb api key
# backwards compatibility will be removed soon
BS_PACKAGE_NEUTRINO_TMDB_API_KEY ?= $(NEUTRINO_TMDB_DEV_KEY)
BS_PACKAGE_NEUTRINO_TMDB_API_KEY ?= $(BS_PACKAGE_NEUTRINO_TMDB_DEV_KEY)
ifeq ($(BS_PACKAGE_NEUTRINO_TMDB_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_TMDB_API_KEY = 7270f1b571c4ecbb5b204ddb7f8939b1
endif

# neutrino: shoutcast developer id
# backwards compatibility will be removed soon
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID ?= $(NEUTRINO_SHOUTCAST_DEV_KEY)
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID ?= $(BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_KEY)
ifeq ($(BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID),$(empty))
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_ID = fa1669MuiRPorUBw
endif

# neutrino: youtube api key
# backwards compatibility will be removed soon
BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY ?= $(NEUTRINO_YOUTUBE_DEV_KEY)
BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY ?= $(BS_PACKAGE_NEUTRINO_YOUTUBE_DEV_KEY)
ifeq ($(BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY),$(empty))
BS_PACKAGE_NEUTRINO_YOUTUBE_API_KEY = AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM
endif

# neutrino: weather api key
# backwards compatibility will be removed soon
BS_PACKAGE_NEUTRINO_WEATHER_API_KEY ?= $(NEUTRINO_WEATHER_DEV_KEY)
BS_PACKAGE_NEUTRINO_WEATHER_API_KEY ?= $(BS_PACKAGE_NEUTRINO_WEATHER_DEV_KEY)
#ifeq ($(BS_PACKAGE_NEUTRINO_WEATHER_API_KEY),$(empty))
#BS_PACKAGE_NEUTRINO_WEATHER_API_KEY =
#endif

# neutrino-mediathek: use plugin from NI plugins repository
BS_PACKAGE_NEUTRINO_MEDIATHEK_ORIGIN_NI ?= y

# vu+ drivers: use latest version
BS_PACKAGE_VUPLUS_DRIVERS_LATEST ?= n
