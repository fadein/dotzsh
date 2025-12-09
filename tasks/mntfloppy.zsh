#!/bin/env zsh

PURPOSE="Mount/unmount /mnt/floppy"
VERSION="1.0"
   DATE="Tue Dec  9 2025"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0
TASKNAME=$0:t:r

MOUNT=/bin/mount
UMOUNT=/bin/umount
MOUNT_POINT=/mnt/floppy


setup() {
    if $MOUNT | grep -q $MOUNT_POINT; then
        die "$MOUNT_POINT is already mounted"
    fi
    raisePrivs
    # detect the first serial device 
    if [[ -z $DEVICE ]]; then
        local devices=(/dev/sd??)
        if [[ -z $devices ]]; then
            die "No pluggable serial device was detected"
        fi
        DEVICE=$devices[1]
    fi
    $MOUNT $DEVICE $MOUNT_POINT
    CLEANUP_TRAPS=(HUP)
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
    logger mntfloppy cleanup $MOUNT_POINT
    if $MOUNT | grep -q $MOUNT_POINT; then
        $UMOUNT --force $MOUNT_POINT
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
