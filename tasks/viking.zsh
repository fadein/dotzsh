#!/bin/zsh

PURPOSE="Log into Viking2 with TMUX"
VERSION=0.6
   DATE="Mon May 18 2026"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SSH=/usr/bin/ssh
CMD="exec /home/fadein/.local/bin/comms.tmux"

HOME_WIFI="get your own internet"
INTRANET_HOST=viking2.falor
INTERNET_HOST=viking-dyn

#spawn our task shell
spawn() {
    if [[ $TERM != 'linux' ]]; then
        LANG=en_US.utf8
    else
        LANG=C
    fi

    # set NULL_GLOB for the duration of this function only
    setopt LOCAL_OPTIONS NULL_GLOB

    case $(uname) in
        Linux)
            case $HOSTNAME in
                    mariner*)
                        HOST=$INTERNET_HOST ;;

                    *)
                        # When at home, connect via $INTRANET_HOST
                        # Otherwise, connect via $INTERNET_HOST
                        HOST=$INTRANET_HOST
                        for WIFI_IFS in /sys/class/net/w*; do
                            WIFI_IFS=$(basename $WIFI_IFS)
                            WIFI="$(iwconfig $WIFI_IFS | \grep ESSID | cut -d'"' -f2)"
                            if [[ $WIFI != $HOME_WIFI ]]; then
                                HOST=$INTERNET_HOST
                                break
                            fi
                        done ;;
            esac ;;

        *)
            HOST=$INTERNET_HOST ;;
    esac

    zmodload zsh/zselect
    local i=0
    until TASK=$TASKNAME $SSH -t $HOST "LANG=$LANG $CMD"; do
        print "Awating a connection to $HOST #$((++i))...\n"
        zselect -t 100  # sleep for 100 centiseconds = 1 second
    done
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
