#!/bin/zsh

#Program: timed.zsh
PURPOSE="Keep track of how long I've spent on a thing"
VERSION=0.2
   DATE="Sun Aug 25 18:42:29 MDT 2019"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

env() {
	_KEEP_FUNCTIONS=(prettySeconds)

	typeset -gA _HELP
	_HELP+=("soFar" "Report how long you've worked on this so far")
	soFar() {
		echo "You've been working on this $( prettySeconds )"
	}

	>&1 <<-MESSAGE
	Use the function 'soFar' to see how long you've been working on this
	MESSAGE
}

# Report on time spent on this task
cleanup() {
	echo You hacked on that for $( prettySeconds )
}

source $0:h/__TASKS.zsh
