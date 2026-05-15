#!/bin/env zsh

PURPOSE="Run Steam through Conty"
VERSION="1.2"
   DATE="Tue Apr 21 2026"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r

setup() {
	if   command -v conty_lite_dwarfs.sh >/dev/null; then
		CONTY=conty_lite_dwarfs.sh
	elif command -v conty_lite.sh >/dev/null; then
		CONTY=conty_lite.sh
	elif command -v conty.sh >/dev/null; then
		CONTY=conty.sh
	else
		print 'Failed to locate a conty*.sh in $PATH; exiting'
		exit 1
	fi

	killall picom
	export CONTY
}

env() {
	# remove sensitive variable NAMES from environment, just in case
	eval unset $(command env | cut -d= -f1 | command grep -E 'OVERRIDE|API|TOKEN|TWINE_USERNAME|TWINE_PASSWORD')
	
	$CONTY steam & disown
	figlet -t "Exit this shell to terminate steam"
}

cleanup() {
	killall steam
	picom & disown
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
