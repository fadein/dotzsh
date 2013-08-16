#!/bin/zsh
PURPOSE='Build Chicken on AIX'
VERSION="1.1"
   DATE="Fri Dec  6 12:41:56 MST 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

case `uname` in
	AIX)
		env() {
			# use gcc 4.4.5, not the old 3.2.2
			PATH=/home/efalor/.storm-dev/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts
			CHICKENDIR=/home/efalor/build/chicken

			#export CSC_OPTIONS='-vv -C -maix64 -L -maix64 -Wl,-R"." -Wl,-bsvr4 -Wl,-bbigtoc'
			#echo "CSC_OPTIONS is exported as a work-around for chicken-install"
			alias make=make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)
			alias vim=/usr/local/bin/vim
			alias screen=/usr/local/bin/screen
			echo "make is aliased to 'make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)'"

			persistentTodo $CHICKENDIR/.todo
			cd $CHICKENDIR
		}
		;;

	Linux)
		env() {

			alias make=make\ PLATFORM=linux\ PREFIX=$HOME/.$(hostname)
			echo "make is aliased to 'make\ PLATFORM=linux\ PREFIX=$HOME/.$(hostname)'"

			persistentTodo ~/chicken/.todo

			gitprompt
			cd ~/chicken/chicken-core.git/
		}
		;;
esac

source $0:h/__TASKS.zsh
