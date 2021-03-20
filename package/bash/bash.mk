################################################################################
#
# bash
#
################################################################################

BASH_VERSION = 5.0
BASH_DIR = bash-$(BASH_VERSION)
BASH_SOURCE = bash-$(BASH_VERSION).tar.gz
BASH_SITE = $(GNU_MIRROR)/bash

BASH_CONF_ENV += \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_sigsetjmp=present \
	bash_cv_printf_a_format=yes

BASH_CONF_OPTS = \
	--bindir=$(base_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--without-bash-malloc

define BASH_TARGET_CLEANUP
	-rm $(addprefix $(TARGET_libdir)/bash/, loadables.h Makefile.inc)
	-rm -f $(addprefix $(TARGET_base_bindir)/, bashbug)
endef
BASH_TARGET_FINALIZE_HOOKS += BASH_TARGET_CLEANUP

define BASH_ADD_TO_SHELLS
	grep -qsE '^/bin/bash$$' $(TARGET_sysconfdir)/shells \
		|| echo "/bin/bash" >> $(TARGET_sysconfdir)/shells
endef
BASH_TARGET_FINALIZE_HOOKS += BASH_ADD_TO_SHELLS

bash: | $(TARGET_DIR)
	$(call autotools-package)
