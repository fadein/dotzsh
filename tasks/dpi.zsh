#!/bin/env zsh

PURPOSE="Temporarily reset Xft DPI"
VERSION="1.1.1"
   DATE="Sun Jan 11 2026"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r
XRDB=/usr/bin/xrdb
FIGLET=$(command -v figlet) || FIGLET=print


setup() {
    print $'\x1b[0m'
    CLEANUP_TRAPS=(HUP)
	old_dpi=$($XRDB -get Xft.dpi)
	print Xft.dpi: ${dpi:-90} | $XRDB -override
	$FIGLET Xft.dpi
	print was $old_dpi
	print is now ${dpi:-90} 
}

cleanup() {
    print $'\x1b[0m'
	if [[ -z $old_dpi ]]; then
		print Xft.dpi | $XRDB -remove
		$FIGLET Xft.dpi
		print has been unset
	else
		print Xft.dpi: ${old_dpi} | $XRDB -override
		old_dpi=$($XRDB -get Xft.dpi)
		$FIGLET Xft.dpi
		print restored to ${old_dpi} 
	fi
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
