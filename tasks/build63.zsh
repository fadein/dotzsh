#!/usr/local/bin/zsh
PURPOSE='Build Spillman 6.3 on AIX'
VERSION="1.0"
   DATE="Wed Jul 31 23:37:56 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

env() {
	# remove /usr/local/bin from PATH to use gcc 4.4.5 instead of the old 3.2.2
	PATH=/home/efalor/.storm-dev/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts

	alias vim=/usr/local/bin/vim
	alias screen=/usr/local/bin/screen

	persistentTodo /opt/debug/efalor/development/spillman-6-3/.todo

	cd /opt/debug/efalor/development/spillman-6-3

	echo "make is aliased to 'make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)'"
}



source $0:h/__TASKS.zsh
