#!/bin/env zsh

PURPOSE="Mount/unmount /mnt/rasp"
VERSION="1.3"
   DATE="Tue Dec  9 2025"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0
TASKNAME=$0:t:r

MOUNT=/bin/mount
UMOUNT=/bin/umount
MOUNT_POINT=/mnt/rasp


setup() {
    if $MOUNT | grep -q $MOUNT_POINT; then
        die "$MOUNT_POINT is already mounted"
    fi
    raisePrivs
    $MOUNT $MOUNT_POINT
    CLEANUP_TRAPS+=(HUP)
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
    logger mntrasp cleanup $MOUNT_POINT
    if $MOUNT | grep -q $MOUNT_POINT; then
        $UMOUNT --force $MOUNT_POINT
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
