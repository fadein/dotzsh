#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.4"
    DATE="Mon Dec 14 13:34:11 MST 2020"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
	raisePrivs
}

env() {
    _KEEP_FUNCTIONS=(prettySeconds)

	local HOURS=4
	if [[ $(stat --format=%Y /var/log/apt/history.log) -le $(( $(=date +%s) - $HOURS * 3600 )) ]]; then
		apt update
	else
		print "'apt update' has been run within the past $HOURS hours, skipping..."
	fi

	_TODO=(
		'$ gitlab-ctl status'
		'$ apt list --upgradable'
		'$ apt upgrade -y'
		'$ gitlab-ctl status'
		'$ cd /opt/gitlab/embedded/service/gitaly-ruby/git-hooks'
		'$ ln -sf post-receive.pl post-receive'
		"Make sure the hook was replaced by pushing a commit"
		"Retire the webpage broadcast message"
		'$ cd; mv gitlab.msg gitlab.msg.old'
        'Make sure that /var/log/gitlab/{errors,huge_repos}.log exist, are 0644 and "git:git"'
		'$ if [[ -f /var/run/reboot-required ]]; then print Reboot is required; else print Reboot is NOT required; fi'
	)
}


# Report on time spent on this task
cleanup() {
	echo This upgrade took $( prettySeconds ) to complete
}


source $0:h/__TASKS.zsh
