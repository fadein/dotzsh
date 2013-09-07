#!/bin/zsh

PURPOSE="Log into viking "
VERSION=0.1
   DATE="Thu Jan 17 15:00:24 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SSH=/usr/bin/ssh

#spawn our task shell
spawn() {
    if [[ $TERM != 'linux' ]]; then
        TERM=xterm TASK=$TASKNAME $SSH -t viking "exec screen -dr"
    else
        TASK=$TASKNAME $SSH -t viking "exec screen -dr"
    fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
