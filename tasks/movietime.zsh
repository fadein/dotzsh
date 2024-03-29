#!/bin/env zsh

PURPOSE="Movie Time!"
VERSION="1.2"
   DATE="Sun Dec 24 20:07:49 MST 2023"
 AUTHOR="Erik"

PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    backlighter !
    case $HOSTNAME in
        endeavour|columbia)
            # Set the DPI for Firefox
            echo Xft.dpi: 132 | xrdb -quiet -override

            # Set the 4k display to 1080p and mirror to HDMI
            xrandr --output eDP-1 --mode 1920x1080 --output HDMI-1 --auto --same-as eDP-1 --set audio on
            sleep .25
            killall picom
            killall -SIGUSR1 conky
            ;;

        apollo)
            xrandr --output HDMI-1 --auto --same-as eDP-1 --set audio on
            ;;
    esac
    CLEANUP_TRAPS=(HUP)
}


cleanup() {
    case $HOSTNAME in
        endeavour|columbia)
            echo Xft.dpi: 200 | xrdb -quiet -override
            xrandr --output eDP-1 --mode 3840x2160 --output HDMI-1 --off --auto
            sleep .25
            picom &>/dev/null & disown
            killall -SIGUSR1 conky
            ;;

        apollo)
            xrandr --output HDMI-1 --off --auto
            ;;
    esac
    backlighter @
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
