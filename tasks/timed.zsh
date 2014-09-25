#!/bin/zsh

#Program: timed.zsh
PURPOSE="Keep track of how long I've spent on a thing"
VERSION=0.1
   DATE="Thu Jan 17 15:00:24 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

# Report on time spent on this task
cleanup() {
	echo You hacked on that for $( prettySeconds )
}

source $0:h/__TASKS.zsh
