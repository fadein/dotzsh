#!/usr/bin/env zsh

PURPOSE="dunnet"
VERSION="1.0"
   DATE="Fri Aug  7 2026"
 AUTHOR="fadein"

PROGNAME=$0
TASKNAME=$0:t:r


STTY=/usr/bin/stty

setup() {
	[[ ! -d ~/games ]] && die "~/games is not a directory"
	[[ ! -f ~/games/fadein.dunnet ]] && die "~/games/fadein.dunnet is not a file"

	cd ~/games

	# disable ^D so I don't accidentally the game
	stty eof "^7" 

	print -Pu2 "%B%F{green}restore fadein.dunnet%f%b\n"
}

spawn() {
	# TASK=$TASKNAME $ZSH_NAME -c "emacs -l batch dunnet" 
	emacs -batch -l dunnet
}

cleanup() {
	stty eof "^D"

	print You were lost in the dungeon for $( prettySeconds )
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
