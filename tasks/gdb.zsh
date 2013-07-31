#!/usr/local/bin/zsh
PURPOSE='Build GDB on AIX'
VERSION="1.0"
   DATE="Wed Jul 31 15:49:31 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

env() {
	# use gcc 4.4.5, not the old 3.2.2
	PATH=/home/efalor/.storm-dev/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts

	LDFLAGS=-bloadmap:gcc.loadmap.txt\ -bnoquiet\ -maix64\ -bsvr4
	CFLAGS=-maix64

	#export CSC_OPTIONS='-vv -C -maix64 -L -maix64 -Wl,-R"." -Wl,-bsvr4 -Wl,-bbigtoc'
	#echo "CSC_OPTIONS is exported as a work-around for chicken-install"
	alias vim=/usr/local/bin/vim
	alias screen=/usr/local/bin/screen

	#persistentTodo /opt/debug/efalor/build/gdb-7.6/.todo

	cd /opt/debug/efalor/build/gdb-7.6
}



source $0:h/__TASKS.zsh
