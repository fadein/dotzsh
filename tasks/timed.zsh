#!/bin/zsh

#Program: timed.zsh
PURPOSE="Keep track of how long I've spent on a thing"
VERSION=0.1
   DATE="Thu Jan 17 15:00:24 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

#external program paths should go here
DATE=/bin/date

STARTED=

#Note the time we begin
setup() {
	STARTED=$( $DATE +%s )
}

# translate seconds into a timestamp "HH:MM:SS"
prettySeconds() {
	local seconds=$1
	local -a backwards
	local i=1

	#convert raw seconds into array=(seconds minutes hours)
	while [[ $seconds -ne 0 ]]; do
		backwards[$i]=$(( $seconds % 60 ))
		let i++ 
		let seconds=$(( $seconds / 60))
	done

	#reverse the array
	local j=1
	[[ $i -gt 0 ]] && let i--
	local -a result
	while [[ $i -gt 1 ]]; do
		result[$j]=${backwards[$i]}
		let j++
		let i--
	done
	result[$j]=${backwards[$i]}

	#print it out
	case $#result in
		3) printf '%02d:%02d:%02d' ${result[@]} ;;
		2) printf '%02d:%02d' ${result[@]} ;;
		1) printf '00:%02d' ${result[@]} ;;
	esac
}

cleanup() {
	NOW=$( $DATE +%s )

	ELAPSED=$( prettySeconds $(( $NOW - $STARTED )) )

	echo You hacked on that for $ELAPSED
}

source $0:h/__TASKS.zsh
