#!/bin/env zsh

PURPOSE="Mount/unmount /mnt/rasp"
VERSION="1.3"
   DATE="Fri Nov 28 2025"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0
TASKNAME=$0:t:r

MOUNT=/bin/mount
UMOUNT=/bin/umount


setup() {
    if $MOUNT | grep -q /mnt/rasp; then
        die "/mnt/rasp is already mounted"
    fi
    raisePrivs
    $MOUNT /mnt/rasp
    CLEANUP_TRAPS=(HUP)
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
    logger mntrasp cleanup
    if $MOUNT | grep -q /mnt/rasp; then
        $UMOUNT --force /mnt/rasp
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
