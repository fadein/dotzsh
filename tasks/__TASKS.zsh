#!/bin/zsh

#
# Instructions
# This file is like a parent-class.  You don't want to mess with it.  To
# create a new task called mytask:
#
# 1. $ cp TEMPLATE.zsh mytask.zsh
# 2. $ chmod +x mytask.zsh
# 3. $ vi mytask.zsh
#
# Inside mytask.zsh you can edit


#
# Program: TASKS.zsh
PURPOSE='Support shelling into a convenient environment'
VERSION=1.0
   DATE="Thu Jan 24 13:41:41 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

#
# External program paths should go here
ZSH=/bin/zsh

# Define a die() function
if ! functions die >/dev/null; then
	die() {
		for line in "$@"; do
			echo -e $line 1>&2
		done
		return 1
	}
fi

#
# Define a todo() shell function that rocks
if ! functions todo >/dev/null; then
	todo() {
		case $1 in
			'') #no extra args, show the next task
				[[ 0 != $#_TODO ]] && print "\n[TODO] $_TODO[1]" ;;

			list) # pretty print the list
				i=0
				width=$#_TODO; width=$#width #poor man's log()
				for T in $_TODO; do
					let i++
					printf "%*d. %s\n" $width $i $T
				done ;;

			next|done) # complete an arbitrary task
				if [[ -z $2 ]]; then
					[[ 0 != $#_TODO ]] && shift _TODO
				elif [[ $2 -le $#_TODO ]]; then
					print "Completed '$_TODO[$2]'"
					_TODO[$2]=()
				fi
				[[ 0 == $#_TODO ]] && print "All done!" || true ;;

			it) # if next task begins with '$', run it as a shell cmd
				if [[ 0 != $#_TODO && ${_TODO[1]#$ } != $_TODO[1] ]]; then
					local cmd=${_TODO[1]#$ }
					eval ${=~cmd}
					local ret=$?
					if [[ 0 == $ret ]]; then
						_TODO[1]=()
						[[ 0 == $#_TODO ]] && print "All done!" || true
					else
						return $ret
					fi
				fi
				;;

			add)  # add a new task to the end of the list
				[[ -n $2 ]] && _TODO+=$argv[2,-1] ;;

			help)
				>&1 <<-HELP
					todo                Print the next task
					todo list           List each task with its index
					todo done [index]   Complete the next (or indexed) task
					todo add TASK       Append TASK to list (quote it!)
				HELP
		esac
	}
fi


#
# Commands to execute when this script is run by the user
if [[ 0 == "$#" && -z "$TASK" ]]; then

	if functions setup >/dev/null; then setup; fi

	if functions spawn >/dev/null; then
		spawn
	else
		TASK=$TASKNAME $ZSH
	fi

	if functions cleanup >/dev/null; then cleanup; fi

#
# Commands to run when this script is sourced above
# (I can tell I'm being sourced only because $TASK is defined)
elif [[ 1 == "$#" && "$TASK" == "$1" ]]; then

	if functions env >/dev/null; then env; fi

	# If a _TODO array was defined in the user's env() function,
	# set up some fun todolist helpers...
	if [[ 0 != $#_TODO ]]; then
		# Remind of the next task with each prompt
		[[ 0 == ${+precmd_functions} || 0 == $precmd_functions[(I)todo] ]] \
			&& precmd_functions+=(todo)
	else
		# or not...
		unfunction todo
	fi

	#clean up the environment
	unfunction setup spawn cleanup env die 2>/dev/null

#
# Do not allow tasks to be recursively entering into
elif [[ -n "$TASK" ]]; then
	function {
		>&1 <<NORECURSION
$1 error:
	You can't recursively enter tasks!  This isn't like Inception!

NORECURSION
	} $TASKNAME

	exit 2

#
# Usage information, such as it is...
else
	function {
	   >&1 <<USAGE
$1 v$VERSION
$DATE
by $AUTHOR

$PURPOSE

Usage:
	$1.zsh (no arguments allowed)

This script sets up a custom environment and launches a child zsh within it.
When the child zsh exits, your previous environment is restored.  In order
for this to work, the child zsh process needs to run the following
instructions on startup:

[[ -n "\$TASK" && -x $2/\$TASK.zsh ]] \\
	&& source $2/\$TASK.zsh \$TASK \\
	|| true  # don't let zsh think that your .zshrc failed!

Be sure to add this snippet to the end of your .zshrc.  While you are within
this task, the TASK environment variable will be populated with this task's
name.

USAGE
	} $TASKNAME $0:a:h

	exit 1
fi

