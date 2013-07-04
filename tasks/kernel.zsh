#!/bin/env zsh

PURPOSE='Rebuild the Kernel'
VERSION="1.2"
   DATE="Fri Apr  5 10:00:45 MDT 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SUDO=/usr/bin/sudo
NICE=/usr/bin/nice
IONICE=/usr/bin/ionice
UMOUNT=/bin/umount

# umount /boot before we begin to avoid clobbering existing files
setup() {
    $UMOUNT /boot
}

# spawn a nice child root shell
spawn() {
	$SUDO TASK=$TASKNAME $IONICE $NICE $ZSH_NAME
}

#
env() {
	_TODO=(
		'Emerge latest kernel sources'
		'Update /usr/src/linux symlink'
        '$ cd /usr/src/linux'
		'$ make menuconfig'
		'$ make'
		'$ make modules'
        '$ ls /boot'
		'$ mount /boot'
		'$ make install modules_install'
        '$ genkernel --install --no-ramdisk-modules initramfs'
		'$ vim /boot/grub/menu.lst'
		'$ module-rebuild rebuild'
		'Rebuild VirtualBox drivers'
		'Reboot!')

	cd /usr/src/linux
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
