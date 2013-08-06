#!/bin/zsh
PURPOSE='Build Chicken on AIX'
VERSION="1.0"
   DATE="Tue Jul  9 22:51:16 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

setup() {
	if [[ `uname` != 'AIX' ]]; then
		die "This task is for AIX"
	fi
}

env() {
	# use gcc 4.4.5, not the old 3.2.2
	PATH=/home/efalor/.storm-dev/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts

	#export CSC_OPTIONS='-vv -C -maix64 -L -maix64 -Wl,-R"." -Wl,-bsvr4 -Wl,-bbigtoc'
	#echo "CSC_OPTIONS is exported as a work-around for chicken-install"
	alias make=make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)
	alias vim=/usr/local/bin/vim
	alias screen=/usr/local/bin/screen
	echo "make is aliased to 'make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)'"

	persistentTodo /home/efalor/build/chicken/.todo

	cd /home/efalor/build/chicken
}



source $0:h/__TASKS.zsh
