#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.7.2"
    DATE="Thu Feb 24 16:30:20 MST 2022"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    [[ -z $STY && -z $TMUX ]] && die "Not using a terminal muxer?  That's just too risky for me."
	raisePrivs || true
}

env() {
    _KEEP_FUNCTIONS=(prettySeconds)

	local HOURS=4
	if [[ $(stat --format=%Y /var/log/apt/history.log) -le $(( $(=date +%s) - $HOURS * 3600 )) ]]; then
		apt update
	else
		printf "'apt update' has been run within the past $HOURS hours, skipping...\n\n"
	fi

	_TODO=(
		'$ apt list --upgradable'
		'$ gitlab-ctl status'
		'$ apt upgrade -y'
		'$ gitlab-ctl status'
		"Make sure the post-receive.pl hook still works by pushing a commit"
		"Retire the webpage broadcast message"
		'$ cd; mv gitlab.msg gitlab.msg.old'
        '$ check-logfile-permissions'
		'$ if [[ -f /var/run/reboot-required ]]; then print Reboot is required; else print Reboot is NOT required; fi'
	)

    typeset -gA _HELP
    _HELP[help]="This function"

    _HELP[check-logfile-permissions]="Verify permissions of important log files"
    check-logfile-permissions() {
        EXPECTED="git:git 644"
        for F in /var/log/gitlab/{huge_repos,errors,pushes}.log; do
            STAT="$(stat -c '%U:%G %a' $F)"
            if [[ $? == 0 && $STAT != $EXPECTED ]]; then
                1>&2 print "Ownership/perms were '$STAT'\n instead of expected '$EXPECTED'\n for file $F\n"
            fi
        done
    }

    BACKUPSDIR=/var/opt/gitlab/backups
    _HELP[backup-gitlab]="Back up GitLab's PostgreSQL database to $BACKUPSDIR"
    backup-gitlab() {
        ding gitlab-backup create
        printf "\nBackup created in $BACKUPSDIR\nNow 'scp' it to viking-dyn:/mnt/rasp/fadein/backups\n"
    }

    _HELP["ls /var/log/apt/"]="APT log files; history GitLab upgrades"
    _HELP['/opt/gitlab/embedded/service/gitlab-shell/hooks']="Location of server hook scripts"

    print "Run 'help' to learn about other tools you can run in this task"
}


# Report on time spent on this task
cleanup() {
	echo This upgrade took $( prettySeconds ) to complete
}


source $0:h/__TASKS.zsh
