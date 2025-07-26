#!/bin/env zsh

PURPOSE="Atlantis's Other Display"
VERSION="1.0"
   DATE="Mon Jun 23 2025"
 AUTHOR="Erik"

PROGNAME=$0
TASKNAME=$0:t:r

XRDB=/usr/bin/xrdb
XRANDR=/usr/bin/xrandr
FIGLET=$(command -v figlet) || FIGLET=print


# On Atlantis, there are several possible DisplayPorts that the HDMI expansion card can appear as.
# This function sets REPLY to the name of the one currently in use and returns True.
# If an HDMI cable is not connected, set REPLY to "" and return False
find-connected-displayport() {
	REPLY=$($XRANDR | awk '/^DisplayPort-[0-9] connected/ { print $1; exit }')
	[[ -n $REPLY ]]
}


setup() {
	CLEANUP_TRAPS=(HUP)

	# Detect a secondary display
	if find-connected-displayport; then
		DISPLAYPORT=$REPLY

		# Set the DPI for Firefox/PyCharm
		old_dpi=$($XRDB -get Xft.dpi)
		print Xft.dpi: ${dpi:-90} | $XRDB -override

		# Turn on the second monitor and position it relative to the primary
		xrandr --output $DISPLAYPORT --${position:-left-of} eDP --auto

		print $'\x1b[0m'
		$FIGLET Xft.dpi
		print is now ${dpi:-90}
	else
		$FIGLET Fail
		print The other display is not connected.
		exit 1
	fi
}


cleanup() {
	if [[ -n $DISPLAYPORT ]]; then
		xrandr --output $DISPLAYPORT --off --auto

		sleep .25
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
		print You were in Other Display mode for $( prettySeconds )
	fi
}


source $0:h/__TASKS.zsh
# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
