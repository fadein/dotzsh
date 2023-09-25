#!/bin/env zsh

PURPOSE="Play on nethack.alt.org"
VERSION="1.0"
   DATE="Sun Sep 24 21:29:03 MDT 2023"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
}

env() {
    clear
    print $'\033]710;xft:hack:pixelsize=48:antialias=true\007Entering the Dungeons of Doom...'
    tcd --scheme=nethack
    ssh nethack@alt.org
}

cleanup() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
