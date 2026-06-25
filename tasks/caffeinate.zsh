#!/usr/bin/env zsh

PURPOSE="caffeinate"
VERSION="1.0"
   DATE="Thu Jun 25 2026"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r

CAF=/usr/bin/caffeinate
CAF_OPTS=(-d -i)

setup() {
	cat <<-':'
	          CH3
	           |
	           N
	         /   \
	N------C       C====O
	||    ||       |
	||    ||       |
	CH     C       N----CH3
	  \  /   \   /            
	   N       C  
	   |       ||
	  CH3      O
	
	:
}

spawn() {
	TASK=$TASKNAME $CAF $CAF_OPTS $ZSH_NAME
}


cleanup() {
	cat <<-':'

	  __
	 /              / /                     /
	(     ___  ___ (    ___  ___       ___ (  ___  ___  ___
	|___ |___)|___)| | |   )|   )     |___ | |___)|___)|   )\   )
	|    |__  |__  | | |  / |__/       __/ | |__  |__  |__/  \_/
	                        __/                        |      /  -   -   -

	:
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
