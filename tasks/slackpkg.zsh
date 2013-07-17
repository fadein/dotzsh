#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.0"
    DATE="Thu Jul  4 12:57:06 MDT 2013"
  AUTHOR="Erik Falor"
TASKNAME=$0:t:r
SLACKPKG=/usr/sbin/slackpkg
SUDO=/usr/bin/sudo

setup() {
	$SLACKPKG update
}

# spawn a (nice) root child shell
spawn() {
	$SUDO TASK=$TASKNAME $NICE -n 10 $ZSH
}

env() {
	_TODO=( "$ slackpkg upgrade-all")

	# Print a useful message to remind the user what to do next
	>&1 <<MESSAGE

### package logs
/var/log/packages
/var/log/removed_packages

### slackpkg ChangeLog location:
/var/lib/slackpkg/ChangeLog.txt
MESSAGE
}

#
# Tie it all together
source $0:h/__TASKS.zsh
