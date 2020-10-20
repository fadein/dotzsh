#!/bin/env zsh

PURPOSE="Tempdir: create a temporary directory under CWD; erase it when done"
VERSION="1.0"
   DATE="Tue Oct 20 13:50:11 MDT 2020"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r

MKTEMP=/usr/bin/mktemp

export _TMPDIR

setup() {
    _TMPDIR=$(mktemp -d $PWD/tmpXXXXXX) || exit 1
}

env() {
    cd $_TMPDIR
}

cleanup() {
    read -q "REPLY?Retain $_TMPDIR? [y/n] "
    print
    case $REPLY in
        Y|y)
            print Leaving $_TMPDIR behind
            ;;
        *)
            rm -rf $_TMPDIR 
            ;;
    esac
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
