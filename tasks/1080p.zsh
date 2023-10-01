#!/bin/env zsh

PURPOSE="enter 1080p mode"
VERSION="1.2"
   DATE="Sun Oct  1 14:13:26 MDT 2023"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    # Set the DPI for Firefox
    echo Xft.dpi: 132 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 1920x1080
    pkill -SIGUSR1 conky
    CLEANUP_TRAPS=(HUP)
}

cleanup() {
    echo Xft.dpi: 220 | xrdb -quiet -override
    xrandr --output eDP-1 --mode 3840x2160 --auto
    pkill -SIGUSR1 conky
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
