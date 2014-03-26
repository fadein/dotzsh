#!/bin/env zsh

PURPOSE="Spillman connect via vpnc"
VERSION="1.0"
   DATE="Wed Jul 31 23:13:08 MDT 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

TASKNAME=$0:t:r

SUDO=/usr/bin/sudo
VPNC=/usr/sbin/vpnc
VPNC_D=/usr/sbin/vpnc-disconnect

setup() {
    $SUDO $VPNC spillman
}

cleanup() {
    $SUDO $VPNC_D
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
