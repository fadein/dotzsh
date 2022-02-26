#!/usr/bin/env zsh

PURPOSE="Broadcast sacrament meeting"
VERSION="1.6"
   DATE="Sun 30 Jan 2022 08:39:41 AM MST"
 AUTHOR="Erik"

PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    if pgrep compton; then
        killall compton
    fi

    if ! pgrep zoom; then
        zoom >/dev/null 2>&1 & disown
    fi

    pavucontrol & disown
    xset -dpms s off
}


env() {
	export LINES COLUMNS
    TM=https://tm.churchofjesuschrist.org

    _HELP+=("reminder" "things to remember about the broadcast")
	reminder() {
		>&1 <<-MESSAGE | pms numberedList | pms colors | pms centerVertical

		Zoom takes several minutes to settle down upon startup.

		Enter the meeting several minutes early so the computer settles down
		and folks can connect.

		Rename myself to "Riverside Ward"

		MESSAGE
	}

	localc ~/Documents/Church/2022Jan29_SacramentMtgPrelude.pptx >/dev/null 2>&1 & disown

    reminder
}

cleanup() {
	if ! pgrep compton; then
		compton &
	fi

    xset +dpms s on
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
