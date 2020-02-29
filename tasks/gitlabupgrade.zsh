#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.1"
    DATE="Sat Feb 29 09:15:09 MST 2020"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
	raisePrivs
}

env() {
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
		'$ gitlab-ctl stop'
		'$ cd /opt/gitlab/embedded/service/gitaly-ruby/git-hooks'
		'$ ln -sf post-receive.pl post-receive'
		'$ cd; mv gitlab.msg gitlab.msg.old'
		"Make sure the hook was replaced by pushing a commit"
		"Retire the broadcast message"
		'$ if [[ -f /var/run/reboot-required ]]; then print Reboot is required; else print Reboot is NOT required; fi'
	)
}

source $0:h/__TASKS.zsh
