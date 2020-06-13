#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.2"
    DATE="Fri Jun 12 19:32:14 MDT 2020"
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
		'$ cd /opt/gitlab/embedded/service/gitaly-ruby/git-hooks'
		'$ ln -sf post-receive.pl post-receive'
		"Make sure the hook was replaced by pushing a commit"
		"Retire the webpage broadcast message"
		'$ cd; mv gitlab.msg gitlab.msg.old'
		'$ if [[ -f /var/run/reboot-required ]]; then print Reboot is required; else print Reboot is NOT required; fi'
	)
}

source $0:h/__TASKS.zsh
