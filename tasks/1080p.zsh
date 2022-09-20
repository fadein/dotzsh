#!/bin/env zsh

PURPOSE="enter 1080p mode"
VERSION="1.1"
   DATE="Mon Sep 12 21:07:39 MDT 2022"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    # Set the DPI for Firefox
    echo Xft.dpi: 132 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 1920x1080
    pkill -SIGUSR1 conky
}

cleanup() {
    echo Xft.dpi: 220 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 3840x2160 --auto
    pkill -SIGUSR1 conky
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
