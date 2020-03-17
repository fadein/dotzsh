#!/bin/env zsh

PURPOSE="Witness"
VERSION="0.1"
   DATE="Tue Mar 17 13:11:21 MDT 2020"
 AUTHOR="ewfalor@gmail.com"

PROGNAME=$0
TASKNAME=$0:t:r

REC_PROG=/usr/bin/parec
REC_OPTS="--format=s16le"
DATE=/usr/bin/date
LAME=/usr/bin/lame
NICE=/usr/bin/nice
MKDIR=/usr/bin/mkdir

export RECORDINGS=~/Recordings

setup() {
    if [[ ! -d $RECORDINGS ]]; then
        $MKDIR -p $RECORDINGS
    fi
}

spawn() {
    FNAME=$(\date -Iseconds).mp3
    $NICE $REC_PROG $REC_OPTS | $LAME --quiet -r -q 3 --lowpass 17 --abr 64 - $RECORDINGS/$FNAME &
    FNAME=$FNAME TASK=$TASKNAME $ZSH_NAME
}


cleanup() {
    print Recorded $FNAME
    kill %%
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
