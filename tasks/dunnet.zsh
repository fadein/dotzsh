#!/usr/bin/env zsh

PURPOSE="dunnet"
VERSION="2.0"
   DATE="Tue Sep  8 2026"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


STTY==stty

setup() {
	[[ ! -d ~/games ]] && die "~/games is not a directory"

	cd ~/games

	# disable ^D so I don't accidentally the game
	$STTY eof "^7" 

	local pmpt
	local press
	print -P -v press "%S[PRESS ANY KEY]%s"
	if [[ -f ~/games/fadein.dunnet ]]; then
		print -P -v pmpt "Run %B%F{green}restore fadein.dunnet%f%b to load progress\n"
	else
		print -P -v pmpt "Run %B%F{green}save fadein.dunnet%f%b in-game to save progress\n"
	fi
	read -k -s "?$pmpt$press"
}

spawn() {
	# TASK=$TASKNAME $ZSH_NAME -c "emacs -l batch dunnet" 
	emacs -batch -l dunnet
}

cleanup() {
	$STTY eof "^D"

	print You were lost in the dungeon for $( prettySeconds )
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
