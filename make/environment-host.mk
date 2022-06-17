#
# set up host environment for other makefiles
#
# -----------------------------------------------------------------------------

HOST_DIR = $(BASE_DIR)/host
HOST_DEPS_DIR = $(HOST_DIR)/deps

# -----------------------------------------------------------------------------

ifndef HOSTAR
HOSTAR := ar
endif
ifndef HOSTAS
HOSTAS := as
endif
ifndef HOSTCC
HOSTCC := gcc
HOSTCC := $(shell which $(HOSTCC) || type -p $(HOSTCC) || echo gcc)
endif
HOSTCC_NOCCACHE := $(HOSTCC)
ifndef HOSTCXX
HOSTCXX := g++
HOSTCXX := $(shell which $(HOSTCXX) || type -p $(HOSTCXX) || echo g++)
endif
HOSTCXX_NOCCACHE := $(HOSTCXX)
ifndef HOSTCPP
HOSTCPP := cpp
endif
ifndef HOSTLD
HOSTLD := ld
endif
ifndef HOSTLN
HOSTLN := ln
endif
ifndef HOSTNM
HOSTNM := nm
endif
ifndef HOSTOBJCOPY
HOSTOBJCOPY := objcopy
endif
ifndef HOSTRANLIB
HOSTRANLIB := ranlib
endif
HOSTAR := $(shell which $(HOSTAR) || type -p $(HOSTAR) || echo ar)
HOSTAS := $(shell which $(HOSTAS) || type -p $(HOSTAS) || echo as)
HOSTCPP := $(shell which $(HOSTCPP) || type -p $(HOSTCPP) || echo cpp)
HOSTLD := $(shell which $(HOSTLD) || type -p $(HOSTLD) || echo ld)
HOSTLN := $(shell which $(HOSTLN) || type -p $(HOSTLN) || echo ln)
HOSTNM := $(shell which $(HOSTNM) || type -p $(HOSTNM) || echo nm)
HOSTOBJCOPY := $(shell which $(HOSTOBJCOPY) || type -p $(HOSTOBJCOPY) || echo objcopy)
HOSTRANLIB := $(shell which $(HOSTRANLIB) || type -p $(HOSTRANLIB) || echo ranlib)

export HOSTAR HOSTAS HOSTCC HOSTCXX HOSTLD
export HOSTCC_NOCCACHE HOSTCXX_NOCCACHE

# -----------------------------------------------------------------------------

HOST_PYTHON_BUILD = \
	CC="$(HOSTCC)" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_LIB_DIR)/site-packages \
	$(HOST_DIR)/bin/python3 ./setup.py build --executable=/usr/python

HOST_PYTHON_INSTALL = \
	CC="$(HOSTCC)" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	LDSHARED="$(HOSTCC) -shared" \
	PYTHONPATH=$(HOST_DIR)/$(HOST_PYTHON3_LIB_DIR)/site-packages \
	$(HOST_DIR)/bin/python3 ./setup.py install --root=$(HOST_DIR) --prefix=
