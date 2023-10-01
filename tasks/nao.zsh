#!/bin/env zsh

PURPOSE="Play on nethack.alt.org or hardfought.org"
VERSION="2.0"
   DATE="Sat Sep 30 22:36:58 MDT 2023"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
    clear
    print $'Entering the Dungeons of Doom...\033]710;xft:hack:pixelsize=48:antialias=true\007'
    tcd --scheme=nethack
}

spawn() {
    case $TASKNAME in
        nao) ssh nethack@alt.org ;;
        hardfought) ssh nethack@hardfought.org ;;
    esac
}

cleanup() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
