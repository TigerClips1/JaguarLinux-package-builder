/* pbuild-sudo.c - limited root privileges for users in "pbuild" group
 *
 * Copyright (C) 2012 Natanael Copa <ncopa@alpinelinux.org>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 as published
 * by the Free Software Foundation. See http://www.gnu.org/ for details.
 */

#include <sys/types.h>

#include <err.h>
#include <grp.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifndef PBUILD_GROUP
#define PBUILD_GROUP "pbuild"
#endif

static const char* valid_cmds[] = {
	"/bin/adduser",
	"/usr/sbin/adduser",
	"/bin/addgroup",
	"/usr/sbin/addgroup",
	"/sbin/ps4",
	"/usr/bin/pbuild-rmtemp",
	NULL
};

static const char* invalid_opts[] = {
	"--allow-untrusted",
	"--keys-dir",
	NULL,
};

const char *get_command_path(const char *cmd)
{
	const char *p;
	int i;
	for (i = 0; valid_cmds[i] != NULL; i++) {
		if (access(valid_cmds[i], F_OK) == -1)
			continue;
		p = strrchr(valid_cmds[i], '/') + 1;
		if (strcmp(p, cmd) == 0)
			return valid_cmds[i];
	}
	return NULL;
}

void check_option(const char *opt)
{
	int i;
	for (i = 0; invalid_opts[i] != NULL; i++)
		if (strcmp(opt, invalid_opts[i]) == 0)
			errx(1, "%s: not allowed option", opt);
}

int is_in_group(gid_t group)
{
	int ngroups_max = getgroups(0, 0);
	gid_t *buf = malloc(ngroups_max * sizeof(gid_t));
	int ngroups;
	int i;
	if (buf == NULL) {
		perror("malloc");
		return 0;
	}
	ngroups = getgroups(ngroups_max, buf);
	for (i = 0; i < ngroups; i++) {
		if (buf[i] == group)
			break;
	}
	free(buf);
	return i < ngroups;
}

int main(int argc, const char *argv[])
{
	struct group *grent;
	const char *cmd;
	const char *path;
	int i;
	struct passwd *pw;

	grent = getgrnam(PBUILD_GROUP);
	if (grent == NULL)
		errx(1, "%s: Group not found", PBUILD_GROUP);

	char *name = NULL;
	uid_t uid = getuid();
	pw = getpwuid(uid);
	if (pw)
		name = pw->pw_name;

	if (uid != 0 && !is_in_group(grent->gr_gid)) {
		errx(1, "User %s is not a member of group %s\n",
			name ? name : "(unknown)", PBUILD_GROUP);
	}

	if (name == NULL)
		warnx("Could not find username for uid %d\n", uid);
	setenv("USER", name ? name : "", 1);

	cmd = strrchr(argv[0], '/');
	if (cmd)
		cmd++;
	else
		cmd = argv[0];
	cmd = strchr(cmd, '-');
	if (cmd == NULL)
		errx(1, "Calling command has no '-'");
	cmd++;

	path = get_command_path(cmd);
	if (path == NULL)
		errx(1, "%s: Not a valid subcommand", cmd);

	for (i = 1; i < argc; i++)
		check_option(argv[i]);

	argv[0] = path;
	/* set our uid to root so bbsuid --install works */
	if (setuid(0) < 0)
		err(1, "setuid(0) failed");
	/* set our gid to root so apk commit hooks run with the same gid as for "sudo apk add ..." */
	if (setgid(0) < 0)
		err(1, "setgid(0) failed");
	execv(path, (char * const*)argv);
	perror(path);
	return 1;
}
