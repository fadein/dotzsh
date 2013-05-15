#!/bin/zsh

PURPOSE='Rebuild the Kernel'
VERSION="1.0"
   DATE="Tue Oct  9 10:26:58 MDT 2012"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SUDO=/usr/bin/sudo
NICE=/usr/bin/nice

spawn() {
	#spawn a nice child root shell
	$SUDO TASK=$TASKNAME $NICE -n 10 $ZSH
}

env() {
	_TODO=( 'Emerge latest sources'
		'Update /usr/src/linux symlink'
		'# make menuconfig'
		'# make modules'
		'# mount /boot'
		'# make install modules_install'
		'Update /boot/grub/menu.lst'
		'Emerge nvidia-driver'
		'Rebuild VirtualBox drivers'
		'Reboot!')
}

source $0:h/__TASKS.zsh
