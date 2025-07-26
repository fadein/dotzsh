#!/bin/env zsh

PURPOSE="enter 1080p mode"
VERSION="1.4"
   DATE="Fri Jul 25 2025"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r

XRDB=/usr/bin/xrdb
FIGLET=$(command -v figlet) || FIGLET=print


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
    print $'\x1b[0m'
    $FIGLET $TASKNAME
    CLEANUP_TRAPS=(HUP)
    old_dpi=$($XRDB -get Xft.dpi)

    # Set the DPI for Firefox
    echo Xft.dpi: 132 | xrdb -quiet -override
    xrandr --output $display --mode 1920x1080
    pkill -SIGUSR1 conky
    CLEANUP_TRAPS=(HUP)
}

cleanup() {
    print $'\x1b[0m'
    xrandr --output $display --mode $resolution --auto
    pkill -SIGUSR1 conky
    if [[ -z $old_dpi ]]; then
        print Xft.dpi | $XRDB -remove
        $FIGLET Xft.dpi
        print has been unset
    else
        print Xft.dpi: ${old_dpi} | $XRDB -override
        old_dpi=$($XRDB -get Xft.dpi)
        $FIGLET Xft.dpi
        print restored to ${old_dpi} 
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
