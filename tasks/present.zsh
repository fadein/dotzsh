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
            # killall picom
            killall -SIGUSR1 conky
            ;;

        apollo)
            xrandr --output HDMI-1 --auto --same-as eDP-1 --set audio on
            ;;
    esac

    #   "https://www.cve.org/CVERecord?id=CVE-2024-38063" \
    #   "https://usu-my.sharepoint.com/:p:/r/personal/a00319537_aggies_usu_edu/_layouts/15/Doc.aspx?sourcedoc=%7BBDAD8835-F8F8-4877-9F95-79CE951F45C7%7D&file=ACC%20Report%202024-2025%20Retreat-r1.pptx&action=edit&mobileredirect=true" \

    ${BROWSER:-firefox} \
        "https://usu-my.sharepoint.com/:p:/r/personal/a00319537_aggies_usu_edu/_layouts/15/Doc.aspx?sourcedoc=%7B4EE0BB89-70BC-41C5-BB41-B2EDF3BF2FA2%7D&file=2024%20CS%20Dept%20Retreat%20Session%209%20-%20Erik.pptx&action=edit&mobileredirect=true&DefaultItemOpen=1&web=1" \
        2>/dev/null 1>&2 &
    CLEANUP_TRAPS=(HUP)
}


cleanup() {
    case $HOSTNAME in
        endeavour|columbia)
            echo Xft.dpi: 200 | xrdb -quiet -override
            xrandr --output eDP-1 --mode 3840x2160 --output HDMI-1 --off --auto
            sleep .25
            # picom &>/dev/null & disown
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
