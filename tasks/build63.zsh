#!/usr/local/bin/zsh
PURPOSE='Build Spillman 6.3 on AIX'
VERSION="1.0"
   DATE="Wed Jul 31 23:37:56 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

env() {

	BUILDDIR=
	case $(hostname) in
		storm*)
			# move /usr/local/bin before /usr/bin in PATH to use gcc 4.4.5
			# instead of the old 3.2.2
			PATH=/home/efalor/.storm-dev/bin:/usr/bin:/usr/local/bin:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts
			BUILDDIR=/opt/debug/efalor/development/spillman-6-3

			alias vim=/usr/local/bin/vim
			alias screen=/usr/local/bin/screen
			alias killall=echo\ "I'm not sure that's such a good idea, boss"

			pgrep() {
				if [[ -z "$1" ]] ; then
					echo Please supply a process name
					return 65
				fi
				local PROC
				PROC=$1
				local PID
				PID=$(ps -e | \grep "[${PROC:0:1}]${PROC:1}" | cut -c2-9)
				[[ -n "$PID" ]] && echo $PID
			}
			>&1 <<-USAGE
			pgrep     - like pgrep(1) on Linux
			killall   - aliased to a noop, for fatfingers
			makeEm    - compile both INDB and Force
			USAGE

			;;

		linux-erik1)
			makeTags() {
				(cd $BUILDDIR && ctags --sort=foldcase --extra=+f -R {force,indb}/{src,include})
			}
			BUILDDIR=/localsds/development/spillman-6-3.git
			>&1 <<-USAGE
			makeEm    - compile both INDB and Force
			makeTags  - use Exuberant Ctags to make tags on sources
			USAGE
			;;
	esac

	makeEm() {
		(cd $BUILDDIR/indb/build && make && (cd $BUILDDIR/force/build && make))
	}

	echo
	persistentTodo $BUILDDIR/.todo
	cd $BUILDDIR
}



source $0:h/__TASKS.zsh
