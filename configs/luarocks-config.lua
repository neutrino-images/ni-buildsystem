
local function getenv(name) return os_getenv(name) or '' end

-- cross-compilation

variables.LUA_INCDIR = getenv('TARGET_INCLUDE_DIR')
variables.LUA_LIBDIR = getenv('TARGET_LIB_DIR')
variables.CC = getenv('TARGET_CC')
variables.LD = getenv('TARGET_LD')
variables.CFLAGS = getenv('TARGET_CFLAGS')
variables.LDFLAGS = getenv('TARGET_LDFLAGS')
variables.LIBFLAG = [[-shared ]] .. getenv('TARGET_LDFLAGS')

external_deps_dirs = { getenv('TARGET_DIR') }
gcc_rpath = false
wrap_bin_scripts = false
deps_mode = [[none]]

-- overriding rocks_trees

rocks_trees = { getenv('TARGET_DIR') }
