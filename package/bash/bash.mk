################################################################################
#
# bash
#
################################################################################

# version 5.0 for CST due to the imperfect implementation of getrandom(2),
# which conflicts with uclibc. See bash-5.0/lib/sh/random.c
BASH_VERSION = $(if $(filter $(BOXTYPE),coolstream),5.0,5.3)
BASH_DIR = bash-$(BASH_VERSION)
BASH_SOURCE = bash-$(BASH_VERSION).tar.gz
BASH_SITE = $(GNU_MIRROR)/bash

BASH_CONF_ENV += \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_sigsetjmp=present \
	bash_cv_printf_a_format=yes

# We want the bash binary in /bin
BASH_CONF_OPTS = \
	--bindir=$(base_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--without-bash-malloc

# 'patch -p0' to apply official patches from $(BASH_SITE)
BASH_PATCH_STRIP = 0

define BASH_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/bash/, loadables.h Makefile.inc)
	$(TARGET_RM) $(addprefix $(TARGET_base_bindir)/, bashbug)
endef
BASH_TARGET_FINALIZE_HOOKS += BASH_TARGET_CLEANUP

# Add /bin/bash to /etc/shells otherwise some login tools like dropbear
# can reject the user connection. See man shells.
define BASH_ADD_TO_SHELLS
	test -d $(TARGET_sysconfdir) || $(INSTALL) -d $(TARGET_sysconfdir)
	grep -qsE '^/bin/bash$$' $(TARGET_sysconfdir)/shells \
		|| echo "/bin/bash" >> $(TARGET_sysconfdir)/shells
endef
BASH_TARGET_FINALIZE_HOOKS += BASH_ADD_TO_SHELLS

bash: | $(TARGET_DIR)
	$(call autotools-package)
