#!/bin/zsh
PURPOSE='Build Chicken on AIX'
VERSION="1.1"
   DATE="Mon Dec  8 09:46:42 MST 2014"
 AUTHOR="Erik Falor <efalor@spillman.com>"
PROGNAME=$0
TASKNAME=$0:t:r

case $(uname) in
	AIX)
		env() {
			# use gcc 4.4.5, not the old 3.2.2
			PATH=/home/efalor/.storm-dev/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/bin

			#export CSC_OPTIONS='-vv -C -maix64 -L -maix64 -Wl,-R"." -Wl,-bsvr4 -Wl,-bbigtoc'
			#echo "CSC_OPTIONS is exported as a work-around for chicken-install"
			alias make=make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)
			alias vim=/usr/local/bin/vim
			alias screen=/usr/local/bin/screen
			echo "make is aliased to 'make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)'"

			persistentTodo /home/efalor/build/chicken/.todo

			cd /home/efalor/build/chicken
		}
		;;

	Linux)
		env() {
			local BUILD=~/build/chicken-5.0.0rc2
			local PREFIX=$BUILD/out
			local MAKE="make PLATFORM=linux PREFIX=$PREFIX"

			PATH=$PREFIX/bin:$PATH
			gitprompt

			alias make=$MAKE
			print "make is aliased to '$MAKE'"


			cat <<- DERP
			http://wiki.call-cc.org/man/5/The%20User%27s%20Manual
			https://wiki.call-cc.org/porting-c4-to-c5
			DERP

			# cd $BUILD
		}
		;;

	CYGWIN_NT*)
		env() {
			alias make=make\ PLATFORM=cygwin\ PREFIX=/usr/local
			echo "make is aliased to 'make\ PLATFORM=cygwin\ PREFIX=/usr/local'"

			cd ~/build/chicken/
			gitprompt
		}
		;;
esac


source $0:h/__TASKS.zsh
