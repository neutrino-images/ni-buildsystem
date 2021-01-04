#
# set up host environment for other makefiles
#
# -----------------------------------------------------------------------------

HOST_DIR      = $(BASE_DIR)/host
HOST_DEPS_DIR = $(HOST_DIR)/deps

# -----------------------------------------------------------------------------

ifndef HOST_AR
HOST_AR := ar
endif
ifndef HOST_AS
HOST_AS := as
endif
ifndef HOST_CC
HOST_CC := gcc
HOST_CC := $(shell which $(HOST_CC) || type -p $(HOST_CC) || echo gcc)
endif
HOST_CC_NOCCACHE := $(HOST_CC)
ifndef HOST_CXX
HOST_CXX := g++
HOST_CXX := $(shell which $(HOST_CXX) || type -p $(HOST_CXX) || echo g++)
endif
HOST_CXX_NOCCACHE := $(HOST_CXX)
ifndef HOST_CPP
HOST_CPP := cpp
endif
ifndef HOST_LD
HOST_LD := ld
endif
ifndef HOST_LN
HOST_LN := ln
endif
ifndef HOST_NM
HOST_NM := nm
endif
ifndef HOST_OBJCOPY
HOST_OBJCOPY := objcopy
endif
ifndef HOST_RANLIB
HOST_RANLIB := ranlib
endif
HOST_AR := $(shell which $(HOST_AR) || type -p $(HOST_AR) || echo ar)
HOST_AS := $(shell which $(HOST_AS) || type -p $(HOST_AS) || echo as)
HOST_CPP := $(shell which $(HOST_CPP) || type -p $(HOST_CPP) || echo cpp)
HOST_LD := $(shell which $(HOST_LD) || type -p $(HOST_LD) || echo ld)
HOST_LN := $(shell which $(HOST_LN) || type -p $(HOST_LN) || echo ln)
HOST_NM := $(shell which $(HOST_NM) || type -p $(HOST_NM) || echo nm)
HOST_OBJCOPY := $(shell which $(HOST_OBJCOPY) || type -p $(HOST_OBJCOPY) || echo objcopy)
HOST_RANLIB := $(shell which $(HOST_RANLIB) || type -p $(HOST_RANLIB) || echo ranlib)

export HOST_AR HOST_AS HOST_CC HOST_CXX HOST_LD
export HOST_CC_NOCCACHE HOST_CXX_NOCCACHE

# -----------------------------------------------------------------------------

HOST_PYTHON_BUILD = \
	CC="$(HOST_CC)" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	LDSHARED="$(HOST_CC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_BASE_DIR)/site-packages \
	$(HOST_DIR)/bin/python3 ./setup.py build --executable=/usr/python

HOST_PYTHON_INSTALL = \
	CC="$(HOST_CC)" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	LDSHARED="$(HOST_CC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_BASE_DIR)/site-packages \
	$(HOST_DIR)/bin/python3 ./setup.py install --root=$(HOST_DIR) --prefix=
