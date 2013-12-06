#!/bin/env zsh
PURPOSE='Build GNU utilities on AIX'
VERSION="1.0"
   DATE="Fri Sep 20 08:46:32 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

setup() {
	if [[ `uname` != 'AIX' ]]; then
		die "This task is for AIX"
	fi
}

env() {
	BUILDDIR=/home/efalor/build/gnu-autotools/

	# use gcc 4.4.5, not the old 3.2.2
	PATH=$HOME/.$(hostname)/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:$HOME/.zsh:$HOME/scripts


	alias configure=./configure\ --with-gnu-ld\ --prefix=$HOME/.$(hostname)
	alias vim=/usr/local/bin/vim
	alias screen=/usr/local/bin/screen

	persistentTodo $BUILDDIR/.todo

	echo "configure is aliased to './configure\ PREFIX=$HOME/.$(hostname)'"
	cd $BUILDDIR
}

source $0:h/__TASKS.zsh
