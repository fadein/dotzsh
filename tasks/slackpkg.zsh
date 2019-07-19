#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.6"
    DATE="Thu Jul 18 18:47:53 MDT 2019"
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
		"\$ $SLACKPKG upgrade-all")

	case $HOSTNAME in
		voyager2*)
			_TODO+=(
				"\$ $SLACKPKG upgrade multilib"
				"\$ $SLACKPKG install multilib"
			)
	esac

	LAST_UPDATE=
	if [[ -f /tmp/slackpkg.last_update.txt ]]; then
		LAST_UPDATE=$(< /tmp/slackpkg.last_update.txt)
		print These new packages have been added to the repo:
		sed -n -e '/Added.$/p' -e "/^$LAST_UPDATE/q" /var/lib/slackpkg/ChangeLog.txt
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

	# /usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k 4.4.75

It should echo back a command including a big list of kernel modules"

case $HOSTNAME in
	voyager2*|mariner*)
		print $IMPORTANT

		if sed -n -e '/a\/kernel-.*/q0' -e "/^$LAST_UPDATE/q1" /var/lib/slackpkg/ChangeLog.txt; then
			_TODO+=(
				'The kernel was updated; run the subsequent commands'
				)
			else
			_TODO+=(
				"The kernel wasn't updated; you may skip the following commands"
				)
		fi

		_TODO+=(
			'$ mount /boot/efi'
			'$ cd /boot/efi/EFI/Slackware/'
			'$ cp /boot/vmlinuz*(.) .'
			'run $(/usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k <KERNEL-VER>)'
			'run cp /boot/initrd.gz initrd-<KERNEL-VER>.gz'
			'edit elilo.conf to point to the new kernel (make it be the 1st entry)'
		)
	;;
esac

}

source $0:h/__TASKS.zsh
