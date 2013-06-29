#!/bin/env zsh

PURPOSE="EXAMPLE Zsh task"
VERSION="***"
   DATE="***"
 AUTHOR="***"

#
# Don't change this assignment - it is very important
# The name of this task shall be the name of this script, minus .zsh
TASKNAME=$0:t:r

#
# I like to refer to programs by absolute path for security.  You
# can do this too, or not.
BASE64=/usr/bin/base64
DATE=/usr/bin/date
DD=/usr/bin/dd
NICE=/usr/bin/nice
RM=/usr/bin/rm
SUDO=/usr/bin/sudo
TEMPFILE=/usr/bin/tempfile

export _TASK_TMPFIL=${_TASK_TMPFIL:-}

#
# Instructions to run one time to set up your environment.  You
# could download a file, update a repository, sync a database, etc.
setup() {
	print "EXAMPLE setup()"

	if [[ -d /dev/shm && -x $DD && -x $BASE64 ]]; then
		_TASK_TMPFIL=$( $TEMPFILE -d /dev/shm )
		print "\tMaking tempfile $_TASK_TMPFIL"
		$DD if=/dev/urandom bs=64 count=1 2>/dev/null \
			| $BASE64 > $_TASK_TMPFIL
	fi
}

# how do you want to start your shell
spawn() {
	print "EXAMPLE spawn()"

	# spawn a (nice) root child shell
	#$SUDO TASK=$TASKNAME $NICE -n 10 $ZSH_NAME

	# this is the default action taken by TASKS.zsh if you
	# don't define this function
	TASK=$TASKNAME $ZSH_NAME
}

#
# Add
env() {
	print "EXAMPLE env()"

	export _FOR_EXAMPLE="This task was entered into @ $DATE"

	if [[ -d /dev/shm && -x /dev/shm ]]; then
		cd /dev/shm
		print "\tLook for your personalized file $_TASK_TMPFIL"
	else
		print "\tY U NO /dev/shm??"
	fi

	#
	# A todo list.  If this variable isn't instantiated, there
	# will be no todo() function in your task environment.
	_TODO=(
		"type 'todo next' to advance to the next item"
		"$ echo type 'todo it' to execute a todo item beginning with $"
		"$ echo That\'s the way!"
		"'todo it' will not remove the $ item when the command fails"
		"$ false"
		"type 'todo help' for instructions"
		"$ todo next"
		"Whoops! You stepped over this item")
	if [[ -n $_TASK_TMPFIL ]]; then
		_TODO+="$ cat $_TASK_TMPFIL"
	fi
	_TODO+="This is the last todo list item"

	#
	# a private, task-specific helper function
	example() {
		print "For example, $_FOR_EXAMPLE"
		if [[ -n $_TASK_TMPFIL ]]; then
			print "Here is your personalized noise"
			cat $_TASK_TMPFIL
		fi
	}

	# Print a useful message to remind the user what to do next
	>&1 <<MESSAGE

###
######
############
########################
#########################################

This example task tries to chdir into /dev/shm.
You will be restored to your former shell at its
former location when you quit this shell.

A helpful function, example() is defined for you
as well.  It will also go away when you exit this
shell.

The text appearing above your prompt is your todo
list.  You can interact with it through the todo()
shell function.  Run 'todo help' for instructions.

#########################################
########################
############
######
###
MESSAGE
}

#
# Undo any changes made by setup(), commit your work, upload a
# file, etc.
cleanup() {
	print "EXAMPLE cleanup()"

	if [[ -d /dev/shm && -x /dev/shm && -e $_TASK_TMPFIL ]]; then
		print "\tCleaning up $_TASK_TMPFIL"
		$RM -f $_TASK_TMPFIL
	fi

	print You hacked on that for $( prettySeconds $SECONDS )
}

#
# Tie it all together
source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
