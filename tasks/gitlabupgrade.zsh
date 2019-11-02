#!/bin/zsh

: <<TODO
* Touch a file that is N hours old and compare it's age to /var/cache/apt.  If
  apt/ is newer than the N hours old file, don't auto run apt update

	>&1 <<-MESSAGE
	MESSAGE
}
TODO

 PURPOSE="GitLab server update task"
 VERSION="1.0"
    DATE="Sat Nov  2 09:36:29 MDT 2019"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
	raisePrivs
}

env() {
	apt update
	_TODO=(
		"\$ gitlab-ctl status"
		"\$ apt list --upgradable"
		"\$ apt upgrade -y"
		"\$ gitlab-ctl status"
		"\$ gitlab-ctl stop"
		"\$ cd /opt/gitlab/embedded/service/gitaly-ruby/git-hooks"
		"\$ ln -sf post-receive.pl post-receive"
		"\$ cd; mv gitlab.msg gitlab.msg.old"
		"Make sure the hook was replaced by pushing a commit"
		"Retire the broadcast message"
		"Reboot if the kernel was updated"
		)


source $0:h/__TASKS.zsh
