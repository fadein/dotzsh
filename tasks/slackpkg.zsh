#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.10"
    DATE="Mon Dec 28 19:10:33 MST 2020"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

SLACKPKG=/usr/sbin/slackpkg
NICE=/usr/bin/nice

setup() {
	raisePrivs
	grep -v '^#' /etc/slackpkg/mirrors || die "You need to uncomment one mirror from /etc/slackpkg/mirrors"
	
	$SLACKPKG update

	[[ -f /var/lib/slackpkg/ChangeLog.txt ]] || die "'$SLACKPKG update' failed, or soemthing else went wrong"

	case $HOSTNAME in
		voyager2*|mariner*|endeavour)
			if ! findmnt /boot/efi >/dev/null 2>&1; then
				modprobe -a fat vfat nls_cp437 nls_iso8859-1 || die "Couldn't insert modules needed to mount /boot/efi"
				mount /boot/efi || die "Couldn't mount /boot/efi"
			else
				print /boot/efi is already mounted
			fi
			;;
	esac
}

# spawn a (nice) root child shell
spawn() {
	TASK=$TASKNAME $NICE -n 10 $ZSH_NAME
}


help() {
	>&1 <<-MESSAGE
	
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
}


env() {

	# ring the bell when the update is received
	print "\C-g"

	_TODO=(
		"\$ $SLACKPKG install-new"
		"\$ $SLACKPKG upgrade-all")

	case $HOSTNAME in
		nevermind*)
			_TODO+=(
				"\$ $SLACKPKG upgrade multilib"
				"\$ $SLACKPKG install multilib"
			)
	esac

	LAST_UPDATE=
	if [[ -f /tmp/slackpkg.last_update.txt ]]; then
		LAST_UPDATE=$(< /tmp/slackpkg.last_update.txt)
		cat <<-BANNER
		
		
		===================================================
		My previous update was $LAST_UPDATE
		===================================================
		
		These new packages have been added to the repo since the last update:
		BANNER
		sed -n -e '/Added.$/p' -e "/^$LAST_UPDATE/q" /var/lib/slackpkg/ChangeLog.txt
	fi

	# Store the date of this update
	head -n1 /var/lib/slackpkg/ChangeLog.txt > /tmp/slackpkg.last_update.txt


	help

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
	voyager2*|mariner*|endeavour)
		print $IMPORTANT

		if sed -n -e '/a\/kernel-generic.*/q0' -e "/^$LAST_UPDATE/q1" /var/lib/slackpkg/ChangeLog.txt; then
			_TODO+=(
				'The kernel was updated; run the subsequent commands'
				)
			else
			_TODO+=(
				"The kernel wasn't updated; you may skip the following commands"
				)
		fi

		_TODO+=(
			'$ cd /boot/efi/EFI/Slackware/'
			'$ cp /boot/vmlinuz*(.) .'
			'run $(/usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k <KERNEL-VER>)'
			'run cp /boot/initrd.gz initrd-<KERNEL-VER>.gz'
			'edit elilo.conf to point to the new kernel (make it the 1st entry)'
		)
	;;
esac

}

# vim: set noexpandtab:
source $0:h/__TASKS.zsh

