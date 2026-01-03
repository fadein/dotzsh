#!/bin/env zsh

PURPOSE="Run Steam through Conty"
VERSION="1.1"
   DATE="Wed Dec 31 2025"
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
	$CONTY steam & disown
	figlet -t "Exit this shell to terminate steam"
}

cleanup() {
	killall steam
	picom & disown
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
