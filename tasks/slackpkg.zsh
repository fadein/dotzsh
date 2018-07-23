#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.4"
    DATE="Tue Jul  3 15:35:13 MDT 2018"
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

	_TODO=(
		"\$ $SLACKPKG install-new"
		"\$ $SLACKPKG upgrade-all"
		"\$ $SLACKPKG upgrade multilib"
		"\$ $SLACKPKG install multilib"
	)

	if [[ -f /tmp/slackpkg.last_update.txt ]]; then
		local last_update=$(< /tmp/slackpkg.last_update.txt)
		print These new packages have been added to the repo:
		sed -n -e '/Added.$/p' -e "/^$last_update/q" /var/lib/slackpkg/ChangeLog.txt
	fi

	# Store the date of this update
	head -n1 /var/lib/slackpkg/ChangeLog.txt > /tmp/slackpkg.last_update.txt

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

MESSAGE

IMPORTANT="

!!!!!!!!!!!!!!!!!
!!! IMPORTANT !!!
!!!!!!!!!!!!!!!!!

After updating the kernel on LVM systems (Voyager2, Mariner), you must copy the
new kernel files into /boot/efi/EFI/Slackware/

Make sure that the vmlinuz file there is replaced by the vmlinuz-generic file.

Next, re-create the initrd Run this command, inserting the version number of
the new kernel:

	# /usr/share/mkinitrd/mkinitrd_command_generator.sh -k 4.4.75

It should echo back a command including a big list of kernel modules"

case $HOSTNAME in
	voyager2*|mariner*)
		if [[ -n $last_update ]]; then
			if sed -n -e '/a\/kernel-.*/q0' -e "/^$last_update/q1" /var/lib/slackpkg/ChangeLog.txt; then
				print $IMPORTANT
				_TODO+=(
				'$ cd /boot/efi/EFI/Slackware/'
				'copy the new vmlinuz* files from /boot to here (not symlinks)'
				'replace the vmlinuz file with vmlinuz-generic'
				'run "/usr/share/mkinitrd/mkinitrd_command_generator.sh -k <kernel ver>"'
				'copy the resulting /boot/initrd.gz up here'
				)
			fi
		else
			print $IMPORTANT
		fi
		;;
esac

}

source $0:h/__TASKS.zsh
