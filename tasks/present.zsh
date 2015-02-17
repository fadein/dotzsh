#!/bin/env zsh

PURPOSE="Presentation mode"
VERSION="1"
   DATE="Mon Feb 16 21:43:41 MST 2015"
 AUTHOR="efalor"

PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    xbindkeys
    xrandr -s 1024x768
}

env() {
    TERM=xterm
    cd ~/bsidesslc/vim-slides.git
}

cleanup() {
    killall xbindkeys
    xrandr -s 1366x768
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
