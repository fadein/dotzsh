#!/bin/zsh

PURPOSE="Log into viking"
VERSION=0.3
   DATE="Sat Aug 12 10:59:40 MDT 2017"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SSH=/usr/bin/ssh
CMD="exec /home/fadein/scripts/comms.tmux"

HOME_WIFI="get your own internet"
INTRANET_HOST=viking2.falor
INTERNET_HOST=viking-dyn
HOST=$INTRANET_HOST

#spawn our task shell
spawn() {
    if [[ $TERM != 'linux' ]]; then
        LANG=en_US.utf8
    else
        LANG=C
    fi

    # If I'm not on my home wifi network, connect
    for WIFI_IFS in /sys/class/net/w*; do
        WIFI_IFS=$(basename $WIFI_IFS)
        WIFI="$(iwconfig $WIFI_IFS | \grep ESSID | cut -d'"' -f2)"
        if [[ $WIFI != $HOME_WIFI ]]; then
            HOST=$INTERNET_HOST
            break
        fi
    done

    TASK=$TASKNAME $SSH -t $HOST "LANG=$LANG $CMD"
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
