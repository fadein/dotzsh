#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.7.1"
    DATE="Mon Nov 29 08:23:23 MST 2021"
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
		'$ cd /opt/gitlab/embedded/service/gitaly-ruby/git-hooks'
		'$ ln -sf post-receive.pl post-receive'
		"Make sure the hook was replaced by pushing a commit"
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

    print "Run 'help' to learn about other tools you can run in this task"
}


# Report on time spent on this task
cleanup() {
	echo This upgrade took $( prettySeconds ) to complete
}


source $0:h/__TASKS.zsh
