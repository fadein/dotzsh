#!/bin/env zsh

PURPOSE="Movie Time!"
VERSION="1.7"
   DATE="Sat Jan  3 2026"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r

XRDB=/usr/bin/xrdb
FIGLET=$(command -v figlet) || FIGLET=print

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
    print $'\x1b[0m'
	$FIGLET $TASKNAME
    CLEANUP_TRAPS=(HUP)
	old_dpi=$($XRDB -get Xft.dpi)
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
                killall picom
            else
                print -P "%B%F{yellow}No external display port was detected%f%b"
                print -P "%B%F{yellow}Switching to 1080p mode%f%b"
                xrandr --output eDP --mode 1920x1080 --auto
            fi
            sleep .25
            ;;
    esac
}


# Prevent Ctrl-D from closing this session w/setopt IGNORE_EOF (-7)
spawn() {
    TASK=$TASKNAME $ZSH_NAME -7
}


cleanup() {
    print $'\x1b[0m'
    case $HOSTNAME in
        endeavour|columbia)
            xrandr --output eDP-1 --mode 3840x2160 --output HDMI-1 --off --auto
            sleep .25
            picom &>/dev/null & disown
            killall -SIGUSR1 conky
            ;;

        apollo)
            xrandr --output HDMI-1 --off --auto
            ;;

        atlantis*)
            if [[ -n $DISPLAYPORT ]]; then
                xrandr --output $DISPLAYPORT --off --output eDP --auto
            else
                xrandr --output eDP --auto
            fi
            picom &>/dev/null & disown
            ;;
    esac

    case $HOSTNAME in
        endeavour|columbia|atlantis*)
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
            ;;
    esac

    backlighter @
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
