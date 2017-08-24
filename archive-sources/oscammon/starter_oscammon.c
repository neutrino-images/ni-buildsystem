/*
 * $Id$
 *
 * shellexec - d-box2 linux project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <plugin.h>
#define SCRIPT "oscammon"

int main()
{
	int ret, pid, status;
	pid=vfork();
	if (pid == -1) {
		fprintf(stderr, "[%s.so] vfork\n", SCRIPT);
		return;
	} else
	if (pid == 0) {
		fprintf(stderr, "[%s.so] forked, executing %s\n", SCRIPT, SCRIPT);
		for (ret=3 ; ret < 255; ret++)
			close (ret);
		ret = execlp(SCRIPT, SCRIPT, NULL);
		if (ret)
			fprintf(stderr, "[%s.so] script return code: %d (%m)\n", SCRIPT, ret);
		else
			fprintf(stderr, "[%s.so] script return code: %d\n", SCRIPT, ret);
		_exit(ret);
	}
	fprintf(stderr, "[%s.so] parent, waiting for child with pid %d...\n", SCRIPT, pid);
	waitpid(pid, &status, 0);
	fprintf(stderr, "[%s.so] parent, waitpid() returned..\n", SCRIPT);
	if (WIFEXITED(status))
		fprintf(stderr, "[%s.so] child returned with status %d\n", SCRIPT, WEXITSTATUS(status));
	return (status);
}
