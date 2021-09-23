#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.5.2"
    DATE="Thu Aug 19 00:14:56 MDT 2021"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
	raisePrivs
    true
}

env() {
    _KEEP_FUNCTIONS=(prettySeconds)

    check-logfile-permissions() {
        EXPECTED="git:git 644"
        for F in /var/log/gitlab/{huge_repos,errors,pushes}.log; do
            STAT="$(stat -c '%U:%G %a' $F)"
            if [[ $? == 0 && $STAT != $EXPECTED ]]; then
                1>&2 print "Ownership/perms were '$STAT'\n instead of expected '$EXPECTED'\n for file $F\n"
            fi
        done
    }

    typeset -gA _HELP
    _HELP[help]="This function"
    _HELP[check-logfile-permissions]="Verify permissions of important log files"
    _HELP["ls /var/log/apt/"]="APT log files; history GitLab upgrades"

	local HOURS=4
	if [[ $(stat --format=%Y /var/log/apt/history.log) -le $(( $(=date +%s) - $HOURS * 3600 )) ]]; then
		apt update
	else
		print "'apt update' has been run within the past $HOURS hours, skipping..."
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
}


# Report on time spent on this task
cleanup() {
	echo This upgrade took $( prettySeconds ) to complete
}


source $0:h/__TASKS.zsh
