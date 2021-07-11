#!/usr/bin/env zsh

PURPOSE="Broadcast sacrament meeting"
VERSION="1.4.1"
   DATE="Sun Jul 11 15:55:49 MDT 2021"
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

		Visit the Liahona network login page @ http://10.1.10.28

		Disable the Wireless Access points in $TM

		Zoom takes several minutes to settle down upon startup.

		Enter the meeting several minutes early so the computer settles down
		and folks can connect.

		Rename myself to "Riverside Ward"

		Go into the security tab and disable
			*	users can unmute themselves
			*	users can chat
			*	users can share their screen

		Go into the participants tab and mute everybody
			*	mute all current and new participants

		Right click my video pane and "Spotlight Video"
		MESSAGE
	}

	localc ~/Documents/Church/2021Q1_SacramentMtgPrelude.pptx >/dev/null 2>&1 & disown

    reminder
    firefox $TM https://usu-edu.zoom.us & disown
}

cleanup() {
	if ! pgrep compton; then
		compton &
	fi

    xset +dpms s on
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
