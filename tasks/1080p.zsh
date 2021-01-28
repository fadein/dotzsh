#!/bin/env zsh

PURPOSE="enter 1080p mode"
VERSION="1.0"
   DATE="Thu Jan 28 13:42:30 MST 2021"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    # Set the DPI for Firefox
    echo Xft.dpi: 132 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 1920x1080
}

cleanup() {
    echo Xft.dpi: 200 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 3840x2160 --auto
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
