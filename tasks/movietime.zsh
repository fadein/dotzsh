#!/bin/env zsh

PURPOSE="Movie Time!"
VERSION="1.4"
   DATE="Mon Jan 27 2025"
 AUTHOR="Erik"

PROGNAME=$0
TASKNAME=$0:t:r


# On Atlantis, there are several possible DisplayPorts that the HDMI expansion card can appear as.
# This function sets REPLY to the name of the one currently in use and returns True.
# If an HDMI cable is not connected, set REPLY to "" and return False
find-connected-displayport() {
    # REPLY=$(xrandr | command grep -o "DisplayPort-. connected" | cut -f1 -d" ")
    REPLY=$(xrandr | awk '/^DisplayPort-[0-9] connected/ { print $1; exit }')
    [[ -n $REPLY ]]
}


# On Atlantis, there are (at least) two possible names for the HDMI sound sink, depending
# on which slot the HDMI expansion card is in.
# This function sets REPLY to the name of the one currently in use and returns True.
# If an HDMI cable is not connected, set REPLY to "" and return False
find-hdmi-sink-name() {
    REPLY=$(pactl list sinks | awk '/^\s*Name: alsa_output.*hdmi/ { print $2; exit }')
    [[ -n $REPLY ]]
}


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

        atlantis*)
            # Set the DPI for Firefox/PyCharm
            echo Xft.dpi: ${dpi:-120} | xrdb -quiet -override

            if find-connected-displayport; then
                DISPLAYPORT=$REPLY

                # Make my screen match the resolution of the projector
                xrandr --output eDP --mode 1920x1080 --auto --output $DISPLAYPORT --same-as eDP --auto

                # restart PulseAudio so it knows that it can play sounds over HDMI
                pactl exit
                sleep .1
                find-hdmi-sink-name && export hdmi_sink=$REPLY
            else
                xrandr --output eDP --mode 1920x1080 --auto
            fi
            sleep .25
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

        atlantis*)
            echo Xft.dpi: 220 | xrdb -quiet -override
            xrandr --output $DISPLAYPORT --off --output eDP --auto
            ;;

    esac
    backlighter @
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
