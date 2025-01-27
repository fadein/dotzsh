#!/bin/env zsh

PURPOSE="enter 1080p mode"
VERSION="1.3"
   DATE="Sun Jan 26 2025"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


case $HOSTNAME in
    atlantis)
        display=eDP
        resolution=2880x1920
        ;;
    columbia|endeavour)
        display=eDP-1 
        resolution=3840x2160
        ;;
esac

setup() {
    # Set the DPI for Firefox
    echo Xft.dpi: 132 | xrdb -quiet -override
    xrandr --output $display --mode 1920x1080
    pkill -SIGUSR1 conky
    CLEANUP_TRAPS=(HUP)
}

cleanup() {
    echo Xft.dpi: 220 | xrdb -quiet -override
    xrandr --output $display --mode $resolution --auto
    pkill -SIGUSR1 conky
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
