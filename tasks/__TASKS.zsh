#!/bin/env zsh
#
# Version: 1.14
# Date:    Thu 18 May 2023 05:07:34 PM MDT
# Author:  Erik Falor <ewfalor@gmail.com>

# Instructions
# This file is like a parent-class.  You don't want to mess with it.  To
# create a new task called mytask:
#
# 1. $ cp EXAMPLE.zsh mytask.zsh
# 2. $ chmod +x mytask.zsh
# 3. $ vi mytask.zsh
#
# Within mytask.zsh add variables, functions and aliases that will
# be useful to you within the context of that task. There are four
# optional functions which you can modify to achieve your environment:
#
#   * setup()
#   * spawn()
#   * env()
#   * cleanup()
#
# When setup() returns non-zero the task is aborted.
#
# Explore EXAMPLE.zsh to see the role each of these functions play.

if ! functions raisePrivs >/dev/null; then
	raisePrivs() {
		if [[ -z "$PROGNAME" ]]; then
			warn "PROGNAME variable is not set in this task!"
			die  "Please put 'PROGNAME=\$0' near the top of this task"
		fi
		[[ $UID != '0' ]] && \
			exec sudo -E _TASK_UID=$UID $PROGNAME
	}
fi

if ! functions dropPrivsAndSpawn >/dev/null; then
	dropPrivsAndSpawn() {
		if [[ $UID == '0' ]]; then
			if [[ -n "$@" ]]; then
				sudo TASK=$TASKNAME -E -u \#$_TASK_UID $@
			else
				sudo TASK=$TASKNAME -E -u \#$_TASK_UID $ZSH_NAME
			fi
		else
			if [[ -n "$@" ]]; then
				TASK=$TASKNAME $@
			else
				TASK=$TASKNAME $ZSH_NAME
			fi
		fi
	}
fi

#
# Print a message to stderr and exit with a failure code
if ! functions die >/dev/null; then
	die() {
		exec 1>&2
		for line in "$@"; do
			echo -e ERROR: $line
		done
		exit 1
	}
fi

if ! functions warn >/dev/null; then
	warn() {
		
		for line in "$@"; do
			echo -e ERROR: $line 1>&2
		done
		return 1
	}
fi

#
# Show a command and then run it
# When the environment variable DRYRUN is non-empty, do not
# actually make any changes, but only show what would be done
if ! functions echodo >/dev/null; then
	echodo() {
		print $@
		if [[ -z $DRYRUN ]]; then
			$@
		else
			true
		fi
	}
fi


#
# Wait for user to press [Enter]
if ! functions pause >/dev/null; then
	pause() { read "?Press [Enter] to continue "; }
fi

if ! functions prettySeconds >/dev/null; then
	prettySeconds() {
		local -i seconds=${1:-$SECONDS}
		local -a result

		for factor in 60 60 24; do
			(( seconds == 0 )) && break
			result=($(( seconds % factor )) ${result[@]})
			seconds=$(( seconds / factor ))
		done
		(( seconds != 0 )) && result=($seconds ${result[@]})

		case ${#result[@]} in
			4) printf '%dd %02d:%02d:%02d' ${result[@]} ;;
			3) printf '%02d:%02d:%02d' ${result[@]} ;;
			2) printf '%02d:%02d' ${result[@]} ;;
			1) printf '00:%02d' ${result[@]} ;;
		esac
	}
fi


if ! functions persistentTodo >/dev/null; then
	persistentTodo() {
		if [[ -n $1 ]]; then
			if [[ -r $1 ]]; then
				typeset -g -a _TODO
				if zmodload zsh/mapfile 2>/dev/null && [[ -f $1 ]]; then
					_TODO=( ${(f)mapfile[$1]} )

					eval "storePersistentTodo() {; print \${(F)_TODO} > $1; }"
					declare -a -g zshexit_functions
					zshexit_functions+=storePersistentTodo
				fi
			else
				"persistentTodo() cannot read file '$1'"
			fi
		else
			print "Usage: persistentTodo(TODOLIST)" 1>&2
		fi
	}
fi

#
# Commands to execute when this script is run by the user
if [[ 0 == "$#" && -z "$TASK" ]]; then

	if functions setup >/dev/null; then setup || exit $?; fi

	if functions spawn >/dev/null; then
		spawn
	else
		TASK=$TASKNAME $ZSH_NAME
	fi

	if functions cleanup >/dev/null; then cleanup; fi

	#
	# Commands to run when this script is sourced above
	# (I can tell I'm being sourced only because $TASK is defined)
elif [[ 1 == "$#" && "$TASK" == "$1" ]]; then

	if functions env >/dev/null; then env; fi

	# If a _TODO array was defined in the user's env() function,
	# set up some fun todolist helpers...
	if [[ $parameters[_TODO] =~ 'array' && 0 != $#_TODO ]]; then
		# Remind of the next task with each prompt
		[[ 0 == ${+precmd_functions} || 0 == $precmd_functions[(I)todo] ]] \
			&& precmd_functions+=(todo)

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

					rm|next|done) # complete an arbitrary task
						if [[ -z $2 ]]; then
							[[ 0 != $#_TODO ]] && shift _TODO
						elif [[ $2 -le $#_TODO ]]; then
							print "Completed '$_TODO[$2]'"
							_TODO[$2]=()
						fi
						[[ 0 == $#_TODO ]] && print "All done!" || true ;;

					skip)
						if [[ -z $2 ]]; then
							print "todo skip: Specify a task to skip to"
						elif (( $2 < 1 )) || (( $2 > ${#_TODO[@]} )); then
							print "todo skip: Task $2 is out of bounds"
						else
							for ((I=1; I<$2; I++)) _TODO[1]=()
						fi
						;;

					it) # if next task begins with '$', run it as a shell cmd
						# any extra arguments are forwarded on to the command
						if [[ 0 != $#_TODO && ${_TODO[1]#$ } != $_TODO[1] ]]; then
							local cmd=${_TODO[1]#$ }
							eval "${=~cmd} $argv[2,$#argv]"
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

					clear) # delete the entire TODO list
						unset _TODO ;;

					help)
						>&1 <<-'HELP'
						todo                   Print the next task
						todo list              List each task with its index
						todo next              Remove the current task
						todo skip index        Skip ahead to the specified task
						todo rm|done [index]   Remove the current (or numbered) task from the list
						todo add TASK          Append TASK to list (quote it!)
						todo clear             Delete the entire list
						todo it [args]         Execute the next task if begins with '$', with any args
						todo help              Show this message
						HELP
						;;
				esac
			}
		fi
	fi

	#
	# If a _HELP associative array was defined in the user's env() function,
	# enable the help function
	if [[ ($parameters[_HELP] =~ 'association') || 0 -lt $#_HELP ]]; then
		if ! functions help >/dev/null; then
			help() {
				print $TASKNAME task help
				print ${(r:${#TASKNAME}::=:)}==========
				print -aC 2 ${(kva)_HELP} | sort
				print
			}
		fi
	fi

	#clean up the environment
	for F in setup spawn cleanup env die prettySeconds persistentTodo \
		pause warn raisePrivs dropPrivsAndSpawn echodo; do
		[[ -z "$_KEEP_FUNCTIONS[(r)$F]" ]] && unfunction $F 2>/dev/null
	done
	unset _KEEP_FUNCTIONS

	#
	# Do not allow tasks to be recursively entering into
elif [[ -n "$TASK" ]]; then
	>&1 <<-NORECURSION
	$TASKNAME error:
	You can't recursively enter tasks!  This isn't like Inception!

	NORECURSION

	exit 2

	#
	# Usage information, such as it is...
else
	>&1 <<-USAGE
	$TASKNAME v$VERSION
	$DATE
	by $AUTHOR

	$PURPOSE

	Usage:
	$TASKNAME.zsh (no arguments allowed)

	This script sets up a custom environment and launches a child zsh within it.
	When the child zsh exits, your previous environment is restored.  In order
	for this to work, the child zsh process needs to run the following
	instructions on startup:

	[[ -n "\$TASK" && -x $0:a:h/\$TASK.zsh ]] \\
		&& source $0:a:h/\$TASK.zsh \$TASK \\
		|| true  # don't let zsh think that your .zshrc failed!

	Be sure to add this snippet to the end of your .zshrc; when it is not present
	the env() function will nod be executed.  While you are within this task, the
	TASK environment variable will be populated with this task's name.

	USAGE

	exit 1
fi

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 noexpandtab:
