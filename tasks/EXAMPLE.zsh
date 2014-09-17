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
# Customize your environment with shell variables, functions, aliases, todo
# lists; chdir into a particular directory, print a helpful usage message,
# etc.
env() {
	print "EXAMPLE env()"
	export _FOR_EXAMPLE="This task was created on $DATE"
    export _WHEN_STARTED="This task was begun at $(date)"

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

	# GLOBAL FOR HELP FUNCTION
    # Put into this association the name of a function followed by a brief description;
    # The user will then be able to run a function 'help' that will show defined functions
    # along with your provided descripion
	typeset -gA _HELP

	#
	# a private, task-specific helper function
    _HELP+=("example" "a private, task-specific helper function")
	example() {
		print "For example, $_FOR_EXAMPLE"
        print $_WHEN_STARTED

		if [[ -n $_TASK_TMPFIL ]]; then
			print "Here is your personalized noise"
			cat $_TASK_TMPFIL
		fi
	}

    _HELP+=("colors" "See if your terminal renders all of the ANSI terminal color codes")
    colors() {
        # Copyright (C) 2011 by Yu-Jie Lin
        #
        # Permission is hereby granted, free of charge, to any person obtaining a copy
        # of this software and associated documentation files (the "Software"), to deal
        # in the Software without restriction, including without limitation the rights
        # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        # copies of the Software, and to permit persons to whom the Software is
        # furnished to do so, subject to the following conditions:
        #
        # The above copyright notice and this permission notice shall be included in
        # all copies or substantial portions of the Software.
        #
        # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
        # THE SOFTWARE.

        fmt="%3d \e[%dmSGR \e[31mSGR \e[44mSGR\e[49m \e[39m\e[44mSGR\e[0m"
        echo
        echo "SGR ($fmt)"
        echo
        for i in {1..25} ; do
                a=()
                for j in {0..75..25}; do
                        a=("${a[@]}" "$((i+j))" "$((i+j))")
                done
                printf "$fmt $fmt $fmt $fmt\n" "${a[@]}"
        done
        echo
        for i in {100..110..4} ; do
                a=()
                for j in {0..3}; do
                        a=("${a[@]}" "$((i+j))" "$((i+j))")
                done
                printf "$fmt $fmt $fmt $fmt\n" "${a[@]}"
        done

        fmt="\e[48;5;%dm   \e[0m"
        echo
        echo "256 Colors ($fmt)"
        echo
        for i in {0..7} ; do printf "%3d " "$i" ; done
        for i in {232..243} ; do printf "%3d " "$i" ; done ; echo
        for i in {0..7} ; do printf "$fmt " "$i" ; done
        for i in {232..243} ; do printf "$fmt " "$i" ; done ; echo

        for i in {8..15} ; do printf  "%3d " "$i" ; done ;
        for i in {244..255} ; do printf "%3d " "$i" ; done ; echo
        for i in {8..15} ; do printf "$fmt " "$i" ; done ;
        for i in {244..255} ; do printf "$fmt " "$i" ; done ; echo
        echo

        fmt="%3d \e[38;5;0m\e[48;5;%dm___\e[0m"
        for i in {16..51} ; do
                a=()
                for j in {0..196..36}; do
                        a=("${a[@]}" "$((i+j))" "$((i+j))")
                done
                printf "$fmt $fmt $fmt $fmt $fmt $fmt\n" "${a[@]}"
        done
    }


    #
    # The utility functions defined in __TASKS.zsh are removed from the
    # environment by default.  If you'd like to keep one around, put
    # its name into this list.
    _KEEP_FUNCTIONS=(die)

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

Run 'help' for usage information regarding commands
within this environment.

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

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
