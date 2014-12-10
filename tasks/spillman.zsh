#!/bin/env zsh

PURPOSE="Spillman connect via vpnc"
VERSION="1.0"
   DATE="Wed Jul 31 23:13:08 MDT 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0
TASKNAME=$0:t:r

VPNC=/usr/sbin/vpnc
VPNC_D=/usr/sbin/vpnc-disconnect

setup() {
    raisePrivs
    $VPNC spillman
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
    $VPNC_D
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
