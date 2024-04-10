#!/bin/env zsh

PURPOSE="Movie Time, but only one screen!"
VERSION="1.2.1"
   DATE="Sun Mar 10 19:32:59 MDT 2024"
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

            # turn off the main 4k display so the backlight doesn't cost battery
            xrandr --output eDP-1 --off

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
    prompt() {

        PRMPT=${@:-press the [ANY] key to begin}
        if [[ -z "$LINES" ]]; then
            LINES=$(tput lines)
        fi
        tput cup $LINES
        [[ -n $SKIP ]] || read -sk1 "REPLY?[7m$PRMPT[0m"
        print

    }

    case $HOSTNAME in
        endeavour|columbia)
            echo Xft.dpi: 200 | xrdb -quiet -override
            xrandr --output eDP-1 --mode 3840x2160 --auto
            sleep .25

            prompt "press ENTER when the main screen comes back"
            
            xrandr --output HDMI-1 --off --auto
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
