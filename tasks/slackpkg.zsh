#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.12"
    DATE="Fri May 28 12:22:55 MDT 2021"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

SLACKPKG=/usr/sbin/slackpkg
NICE=/usr/bin/nice
LAST_UPDATE_FILE=/var/lib/slackpkg/last_update


setup() {
	raisePrivs
	grep -v '^#' /etc/slackpkg/mirrors || die "You need to uncomment one mirror from /etc/slackpkg/mirrors"
	
	$SLACKPKG update

	[[ -f /var/lib/slackpkg/ChangeLog.txt ]] || die "The ChangeLog is missing; either '$SLACKPKG update' failed or something else went wrong"

	case $HOSTNAME in
		voyager2*|mariner*|endeavour|columbia)
			if ! findmnt /boot/efi >/dev/null 2>&1; then
				modprobe -a fat vfat nls_cp437 nls_iso8859-1 || die "Couldn't insert modules needed to mount /boot/efi"
				mount /boot/efi || die "Couldn't mount /boot/efi"
			else
				print /boot/efi is already mounted
			fi
			;;
	esac
}

# Spawn a (nice) child shell
# This will be a root shell by virtue of raisePrivs() having been run in setup()
spawn() {
	TASK=$TASKNAME $NICE -n 10 $ZSH_NAME
}


kernelUpdateInstrs() {
	cat <<-MSG
	After updating the kernel on LVM systems (Voyager2, Mariner), you must copy the
	new kernel files into /boot/efi/EFI/Slackware/

	Make sure that the vmlinuz file there is replaced by the vmlinuz-generic file.

	Next, re-create the initrd by running this command, inserting the version
	number of the new kernel:

	    # /usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k 5.10.6

	It should echo back a command including a big list of kernel modules
	MSG
}


usage() {
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


recordTimeOfLastUpdate() {
	head -n1 /var/lib/slackpkg/ChangeLog.txt > $LAST_UPDATE_FILE
}

env() {
	# Support for help function
	typeset -gA _HELP
	_HELP+=(usage "Instructions for using this task"
	        kernelUpdateInstrs "EFI+ELILO kernel configuration"
	)

	# ring the bell after the update is received
	print "\C-g"

	# Report which packages have changed since the last time I ran an update
	LAST_UPDATE=
	if [[ -f $LAST_UPDATE_FILE ]]; then
		LAST_UPDATE=$(< $LAST_UPDATE_FILE)
		cat <<-BANNER
		
		
		===================================================
		My previous update was $LAST_UPDATE
		===================================================
		
		These new packages have been added to the repo since the last update:
		BANNER
		sed -n -e '/Added.$/p' -e "/^$LAST_UPDATE/q" /var/lib/slackpkg/ChangeLog.txt
	else
		cat <<-BANNER
		
		
		===================================================
		\$LAST_UPDATE is unset; no updates have occurred
		===================================================
		BANNER
	fi

	# Check whether a slackpkg update is on tap and do it first
	if sed -n -e "/ap\/slackpkg.*/q0" -e "/^$LAST_UPDATE/q1" /var/lib/slackpkg/ChangeLog.txt; then
		_TODO=(
			"$ slackpkg upgrade slackpkg"
			"$ slackpkg update"
		)
	else
		_TODO=()
	fi

	_TODO+=(
		"\$ $SLACKPKG install-new"
		"\$ $SLACKPKG upgrade-all"
		"\$ recordTimeOfLastUpdate" # Store the date of this update in /tmp
	)

	# add this host's name if I'm running multilib here
	case $HOSTNAME in
		nevermind*)
			_TODO+=(
				"\$ $SLACKPKG upgrade multilib"
				"\$ $SLACKPKG install multilib"
			)
			;;
	esac



	case $HOSTNAME in
		voyager2*|mariner*|endeavour|columbia)

			# Check whether a kernel update is on tap
			if sed -n -e "/a\/kernel-generic.*/q0" -e "/^$LAST_UPDATE/q1" /var/lib/slackpkg/ChangeLog.txt; then
				KERNEL_VER=$(sed -n -e '/a.kernel-generic/{ s/a.kernel-generic-\([^-]*\)-.*$/\1/p; q }' /var/lib/slackpkg/ChangeLog.txt)
				UPDATED=1
				_TODO+=("The kernel was updated; run the subsequent commands")
			else
				KERNEL_VER="<KERNEL_VER>"
				UPDATED=
				_TODO+=("The kernel wasn't updated; you may skip the following commands")
			fi

			_TODO+=(
				"$ cd /boot/efi/EFI/Slackware/"
				"$ cp /boot/vmlinuz*(.) ."
			)

			if [[ -n $UPDATED ]]; then
				_TODO+=(
					"$ \$(/usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k $KERNEL_VER)"
					"$ cp /boot/initrd.gz initrd-$KERNEL_VER.gz"
				)
			else
				_TODO+=(
					"Run \$(/usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k $KERNEL_VER)"
					"Run cp /boot/initrd.gz initrd-$KERNEL_VER.gz"
				)
			fi

			_TODO+=(
				"Make the new kernel become the 1st entry in elilo.conf"
			)
		;;
	esac

	usage
}

# vim: set noexpandtab:
source $0:h/__TASKS.zsh
