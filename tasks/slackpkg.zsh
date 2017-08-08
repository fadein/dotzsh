#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.2"
    DATE="Sun Jul 16 21:18:06 MDT 2017"
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
	print Updating package lists...
	$SLACKPKG update

	# TODO: make this smart - save the latest update timestamp to some file,
	# and use that for the comparison instead of this janky, hardcoded stamp.
	# Also, I don't believe that this bit works, anyway.
	print These new packages have been added to the repo:
	local last_update="Thu Sep 17 20:15:00 UTC 2015"
	sed -n -e '/Added.$/p' -e "/^$last_update/q" /var/lib/slackpkg/ChangeLog.txt

	_TODO=(
		"$ $SLACKPKG install-new"
		"$ $SLACKPKG upgrade-all"
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


!!! IMPORTANT !!!
If the kernel is one of the packages that is updated, be sure to copy the new
kernel files into /boot/efi/EFI/Slackware/

Make sure that the vmlinuz file there is replaced by the vmlinuz-huge file.

-- OR --

Try running /usr/share/mkinitrd/mkinitrd_command_generator.sh using the new
kernel version number along with the -o output option pointing into
/boot/efi/EFI/Slackware/. The kernels and initrds in /boot don't matter.
It's what's in the EFI/Slackware directory that matter.
MESSAGE
}

source $0:h/__TASKS.zsh
