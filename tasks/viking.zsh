#!/bin/zsh

PURPOSE="Log into viking "
VERSION=0.2
   DATE="Tue Jul  7 17:49:43 MDT 2015"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SSH=/usr/bin/ssh
HOST=viking2.falor

CMD="exec /home/fadein/scripts/comms.tmux"

#spawn our task shell
spawn() {
    if [[ $TERM != 'linux' ]]; then
        LANG=en_US.utf8
    else
        LANG=C
    fi
    TASK=$TASKNAME $SSH -t $HOST "LANG=$LANG $CMD"
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:

