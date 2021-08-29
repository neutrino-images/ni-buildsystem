################################################################################
#
# This file contains various configurations used by the packages.
# Configuration keys may be overridden in config.local
#
################################################################################

# ffmpeg: build ffplay
BS_PACKAGE_FFMPEG_FFPLAY ?= n

# ncurses: build wide-character libraries
BS_PACKAGE_NCURSES_WCHAR ?= y

# neutrino: use ffmpeg audio decoder
BS_PACKAGE_NEUTRINO_AUDIODEC_FFMPEG ?= y

# neutrino: omdb api key
BS_PACKAGE_NEUTRINO_OMDB_API_KEY ?= $(NEUTRINO_OMDB_API_KEY)
BS_PACKAGE_NEUTRINO_OMDB_API_KEY ?= 20711f9e

# neutrino: shoutcast api key
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_KEY ?= $(NEUTRINO_SHOUTCAST_DEV_KEY)
BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_KEY ?= fa1669MuiRPorUBw

# neutrino: tmdb api key
BS_PACKAGE_NEUTRINO_TMDB_DEV_KEY ?= $(NEUTRINO_TMDB_DEV_KEY)
BS_PACKAGE_NEUTRINO_TMDB_DEV_KEY ?= 7270f1b571c4ecbb5b204ddb7f8939b1

# neutrino: youtube api key
BS_PACKAGE_NEUTRINO_YOUTUBE_DEV_KEY ?= $(NEUTRINO_YOUTUBE_DEV_KEY)
BS_PACKAGE_NEUTRINO_YOUTUBE_DEV_KEY ?= AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM

# neutrino: weather api key
BS_PACKAGE_NEUTRINO_WEATHER_DEV_KEY ?= $(NEUTRINO_WEATHER_DEV_KEY)
BS_PACKAGE_NEUTRINO_WEATHER_DEV_KEY ?=
