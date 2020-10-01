#!/bin/zsh

#Program: screensaver.zsh
PURPOSE="Temporarily disable display powersave mode"
VERSION=1.0
   DATE="Sun Sep 27 07:20:38 MDT 2020"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

setup() {
    xset -dpms s off
}

cleanup() {
    xset +dpms s on
}

source $0:h/__TASKS.zsh
