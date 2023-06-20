#!/bin/zsh

 PURPOSE="Slackware update task"
 VERSION="1.15"
    DATE="Mon Jun 19 19:06:51 MDT 2023"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

SLACKPKG=/usr/sbin/slackpkg
NICE=/usr/bin/nice
LAST_UPDATE_FILE=/var/lib/slackpkg/last_update
REBOOT_FILE=/var/run/needs_restarting


setup() {
	raisePrivs
	grep -qv '^#' /etc/slackpkg/mirrors || die "You need to uncomment one mirror from /etc/slackpkg/mirrors"
	
	local HOURS=4 CHANGELOG=/var/lib/slackpkg/ChangeLog.txt
	if [[ ( ! -f $CHANGELOG ) || $(stat --format=%Y $CHANGELOG) -le $(( $(=date +%s) - $HOURS * 3600 )) ]]; then
		$SLACKPKG update
	else
		print "'slackpkg update' has been run within the past $HOURS hours, skipping..."
	fi

	[[ -f $CHANGELOG ]] || die "The ChangeLog is missing; either '$SLACKPKG update' failed or something else went wrong"

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

	    # /usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k 5.19.17 -a '-l colehack'

	It should echo back a command including a big list of kernel modules.
	Wrap that command in '$()' to execute it
	MSG
}


rpiKernelUpdateInstrs() {
	cat <<-MSG
	Viking2 is an RPi3 Armv7 w/Hard float

	The files come from https://slackware.uk/sarpi/rpi3/current-armv7/
	General instructions: https://sarpi.penthux.net/index.php?p=installer

	* Visit https://slackware.uk/sarpi/rpi3/current-armv7/ to see Kernel version and build date
	* VER=(kernel version) DATE=(06Jan22)
	* Ensure that ARCH=(armv7-1), TAG=(sp1) and BUILD=(slackcurrent) are all correct
	MSG
}

usage() {
	>&1 <<-MESSAGE
	
	### Package logs
	/var/log/packages
	/var/log/removed_packages
	
	### View the Slackware ChangeLog
	slackpkg show-changelog
	
	### Install new packages added since last update:
	\$ $SLACKPKG install-new
	
	### When you're ready to upgrade the set of installed packages:
	\$ $SLACKPKG upgrade-all
	
	MESSAGE
}


recordTimeOfLastUpdate() {
	head -n1 /var/lib/slackpkg/ChangeLog.txt > $LAST_UPDATE_FILE
}


assert-initrd-has-colehack() {
	if ! tar ztf /usr/share/mkinitrd/keymaps.tar.gz | grep -q colehack; then
		print "Adding colehack.bmap to /usr/share/mkinitrd/keymaps.tar.gz..."
		loadkeys -b colehack > colehack.bmap
		gunzip -c /usr/share/mkinitrd/keymaps.tar.gz > /tmp/keymaps.tar
		tar -rvf /tmp/keymaps.tar colehack.bmap
		gzip -f /tmp/keymaps.tar
		mv -f /usr/share/mkinitrd/keymaps.tar.gz{,.bak}
		mv /tmp/keymaps.tar.gz /usr/share/mkinitrd/keymaps.tar.gz
	else
		print "colehack.bmap is already present"
	fi
}

getSARPIpkg() {
	if [[ -f $1.txz ]]; then
		echo Already have $1.txz
	elif [[ $1 = *source* ]]; then
		echo Getting src/$1.txz
		wget $BASE/src/$1.txz
	else
		echo Getting pkg/$1.txz
		wget $BASE/pkg/$1.txz
	fi

	if [[ -f $1.md5 ]]; then
		echo Already have $1.md5
	elif [[ $1 = *source* ]]; then
		echo Getting src/$1.md5
		wget $BASE/src/$1.md5
	else
		echo Getting pkg/$1.md5
		wget $BASE/pkg/$1.md5
	fi

	if ! md5sum -c $F.md5; then
		print ====================
		print = MD5 sum mismatch = $F
		print ====================
	fi
	print
}


getAllSARPIpkgs() {
	DESC=${ARCH}_${BUILD}_${DATE}_${TAG}
	for F in \
		kernel_sarpi3-${KVER}-${DESC}  \
		kernel-headers-sarpi3-${KVER}-${DESC}  \
		kernel-modules-sarpi3-${KVER}-${DESC}  \
		sarpi3-boot-firmware-${DESC} \
		sarpi3-hacks-3.0-${DESC} \
		sarpi3-kernel-source-${KVER}-${DESC}
	do
		getSARPIpkg $F
	done
}

setSARPIvars() {
	while true; do
		for V in KVER DATE; do
			vared -p "Set value for $V=" $V
		done
		read -k1 '?Proceed? [Y/n] '
		case $REPLY in
			''|y|Y) break ;;
		esac
	done
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
		"\$ $SLACKPKG install-new || true"
		"\$ $SLACKPKG upgrade-all"
		"\$ recordTimeOfLastUpdate" # Store the date of this update in /tmp
		"\$ $SLACKPKG new-config" # Merge .new files under /etc"
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


	# per-architecture Kernel configuration
	case $(uname -m) in
		x86_64)
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
				"$ assert-initrd-has-colehack"
				"$ \$(/usr/share/mkinitrd/mkinitrd_command_generator.sh -r -k $KERNEL_VER -a '-l colehack')"
				"$ cp /boot/initrd.gz initrd-$KERNEL_VER.gz"
				"Make the new kernel become the 1st entry in elilo.conf"
			)
		;;

		armv7l)
			BASE=https://slackware.uk/sarpi/rpi3/current-armv7
			KVER=5.15.13
			ARCH=armv7-1
			BUILD=slackcurrent
			DATE=06Jan22
			TAG=sp1

			if [[ ! -d SARPI ]]; then
				mkdir SARPI
			fi
			pushd SARPI

			_TODO+=(
			"$ setSARPIvars"
			"$ getAllSARPIpkgs"
			"$ for F in *.txz; do upgradepkg --install-new --reinstall \$F; done"
			"$ cp -R /mnt/mmcblk0p1 $(uname -r).bak"
			"$ command cp -R /boot/* /mnt/mmcblk0p1"
			)
			;;

	esac

	_TODO+=(
        "$ [[ -f $REBOOT_FILE ]] && System must be restarted || print System DOES NOT need to be restarted"
	)

	usage
}

# vim: set noexpandtab:
source $0:h/__TASKS.zsh
