#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.1"
    DATE="Fri Sep 18 23:46:58 MDT 2015"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

SLACKPKG=/usr/sbin/slackpkg
NICE=/usr/bin/nice

setup() {
	raisePrivs
}

# spawn a (nice) root child shell
spawn() {
	TASK=$TASKNAME $NICE -n 10 $ZSH_NAME
}

env() {
	$SLACKPKG update
	$SLACKPKG upgrade-all

	_TODO=(
		"\$ $SLACKPKG install-new"
		"\$ $SLACKPKG upgrade-all"
	)


	>&1 <<MESSAGE


### package logs
/var/log/packages
/var/log/removed_packages

### slackpkg ChangeLog location:
/var/lib/slackpkg/ChangeLog.txt


Run this command to install new packages added since last update:
	\$ $SLACKPKG install-new

Run this command when you're ready to upgrade the set of installed packages:
	\$ $SLACKPKG upgrade-all


After updating the kernel on LVM systems (Voyager2, Mariner), you must re-create the initrd
Run this command, inserting the version number of the new kernel:

	# /usr/share/mkinitrd/mkinitrd_command_generator.sh -k 4.4.75

It should echo back a command including a big list of kernel modules
MESSAGE
}

source $0:h/__TASKS.zsh
