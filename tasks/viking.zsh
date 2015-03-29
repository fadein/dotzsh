#!/bin/zsh

PURPOSE="Log into viking "
VERSION=0.1
   DATE="Thu Jan 17 15:00:24 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SSH=/usr/bin/ssh
HOST=viking2.falor

#spawn our task shell
spawn() {
    if [[ $TERM != 'linux' ]]; then
        LANG=C TERM=xterm TASK=$TASKNAME $SSH -t $HOST "exec screen -dr"
    else
        LANG=C TASK=$TASKNAME $SSH -t $HOST "exec screen -dr"
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
