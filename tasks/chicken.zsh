#!/bin/env zsh
PURPOSE='Build Chicken on AIX'
VERSION="1.1"
   DATE="Fri Dec  6 12:41:56 MST 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

<<<<<<< HEAD
case `uname` in
	AIX)
		env() {
			export CHICKENDIR=/work/efalor/chicken-core.git/
			# use gcc 4.4.5, not the old 3.2.2
			PATH=$HOME/.$(hostname)/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:$HOME/bin:/usr/bin/X11:/sbin:$HOME/.zsh:$HOME/scripts
			export LIBRARY_PATH=$CUSTOMDIR/lib

			#export CSC_OPTIONS='-vv -C -maix64 -L -maix64 -Wl,-R"." -Wl,-bsvr4 -Wl,-bbigtoc'
			#echo "CSC_OPTIONS is exported as a work-around for chicken-install"
			alias make=make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)
			alias vim=/usr/local/bin/vim
			alias screen=/usr/local/bin/screen

			# back up a copy of an installed (and known-to-work) Chicken
			chicken-lifeboat() {
				local REVISION=$(git describe HEAD)
				local LIFEBOAT=$REVISION.tar
				(
				tar cvf $CUSTOMDIR/$LIFEBOAT \
					$CUSTOMDIR/{lib/chicken,lib/libchicken*,include/chicken,bin/chicken*,bin/cs{c,i}} \
					$CHICKENDIR/chicken $CHICKENDIR/chicken-bug $CHICKENDIR/chicken-install \
					$CHICKENDIR/chicken-profile $CHICKENDIR/chicken-status $CHICKENDIR/chicken-uninstall \
					$CHICKENDIR/chicken.import.so $CHICKENDIR/csc $CHICKENDIR/csi \
					$CHICKENDIR/csi.import.so $CHICKENDIR/data-structures.import.so \
					$CHICKENDIR/extras.import.so $CHICKENDIR/files.import.so $CHICKENDIR/foreign.import.so \
					$CHICKENDIR/identify.sh $CHICKENDIR/irregex.import.so $CHICKENDIR/libchicken.so \
					$CHICKENDIR/lolevel.import.so $CHICKENDIR/ports.import.so $CHICKENDIR/posix.import.so \
					$CHICKENDIR/setup-api.import.so $CHICKENDIR/setup-api.so \
					$CHICKENDIR/setup-download.import.so $CHICKENDIR/setup-download.so \
					$CHICKENDIR/srfi-1.import.so $CHICKENDIR/srfi-13.import.so $CHICKENDIR/srfi-14.import.so \
					$CHICKENDIR/srfi-18.import.so $CHICKENDIR/srfi-4.import.so $CHICKENDIR/srfi-69.import.so \
					$CHICKENDIR/tcp.import.so $CHICKENDIR/utils.import.so

				if [[ -f $CHICKENDIR/$REVISION.buildlog.txt ]]; then
					tar uvf $CUSTOMDIR/$LIFEBOAT $CHICKENDIR/$REVISION.buildlog.txt 
				fi

				echo Created $CUSTOMDIR/$LIFEBOAT
				)
			}

			# make a new chicken-boot, and rebuild chicken from that
			reboot() {
				(
				local SHUSH=1
				cd $CHICKENDIR
				touch build-version.c
				if make PLATFORM=aix PREFIX=$HOME/.$(hostname) distclean boot-chicken; then
					touch build-version.c
					make PLATFORM=aix PREFIX=$HOME/.$(hostname) CHICKEN=./chicken-boot
				fi
				)
			}

			dump() {
				[[ -n "$1" ]] && /usr/bin/dump -Xany -n $1 | head -20
			}

			# persistentTodo $CHICKENDIR/.todo

			echo "make is aliased to 'make\ PLATFORM=aix\ PREFIX=$HOME/.$(hostname)'"
			echo "dump() is 'dump -X64 -n \$1 | head -20'"
			echo "use chicken-lifeboat() to back up a copy of an installed (and known-to-work) Chicken"
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
