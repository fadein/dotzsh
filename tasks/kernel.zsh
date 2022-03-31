#!/bin/env zsh

PURPOSE="Rebuild the Kernel on Slackware"
VERSION="1.3"
   DATE="Thu Apr  1 16:28:47 MDT 2021"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0
TASKNAME=$0:t:r

GREP=/usr/bin/grep
SUDO=/usr/bin/sudo
NICE=/usr/bin/nice
IONICE=/usr/bin/ionice
UMOUNT=/bin/umount


# umount /boot/efi before we begin to avoid clobbering existing files
setup() {
    raisePrivs
    if $GREP -q /boot/efi /etc/mtab; then
        $UMOUNT /boot/efi
    fi
}

# spawn a nice child root shell
spawn() {
	TASK=$TASKNAME $IONICE $NICE $ZSH_NAME
}

#
env() {
	_TODO=(
		'$ make menuconfig'
		'$ make'
		'$ make bzImage'
		'$ make modules'
		'$ make modules_install'
        '$ gzip -c vmlinux > vmlinuz'
        'Copy arch/x86/boot/bzImage to /boot/efi/EFI/Slackware/, name it vmlinuz-release#'
        'Copy System.map to /boot, name it after the release #'
        '$ ls /boot/efi'
		'$ mount /boot/efi'
		'$ pushd /boot/efi/EFI/Slackware'
        '$ vim elilo.conf'
		'Reboot!')

	cd /usr/src/linux
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
