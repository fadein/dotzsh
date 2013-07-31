#!/bin/env zsh

PURPOSE="Assist in debugging Spillman & pulling build from penguin.sti"
VERSION="1.3"
   DATE="Tue Jul 30 12:24:48 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"

#
# Don't change this assignment - it is very important
# The name of this task shall be the name of this script, minus .zsh
TASKNAME=$0:t:r

#
# refer to programs by absolute path for security.
SPILL=/usr/local/bin/spillman
RSYNC=/usr/bin/rsync

#
# rsync options
  RSYNC_MERGE=(-irlpDz --stats)
RSYNC_REPLACE=(-irlpDz --stats --del -v)
RSYNC_HOST=sds@linux-erik1
RSYNC_BASE=/sti/development/spillman-6-3.git

spawn() {
	TASK=$TASKNAME $SPILL -h -s $ZSH_NAME
}

#
# Set up the environment the way I like;
env() {
    # chdir into Spillman base area
    cd $BASE

    # GLOBAL VARS
    TERM=xterm
    INTERFACES_HOME=${CATALINA_HOME/tomcat/interfaces-server}

    # GLOBAL FOR HELP FUNCTION
    FUNC_HELP=()
 
    # LITTLE FUNCTIONS
    pause() { read -p "Press [Enter] to continue "; }

    # Function descriptions
    D=

    D="Run rsync and pull changes to INDB in from $RSYNC_HOST"
    rsyncINDB() {
        (
		BASE=$BASE/app/stow/built

        #suppress directory notes
        SHUSH=1

        #sync sources
        mkdir -p $BASE/src
        cd $BASE/src
        $RSYNC $RSYNC_MERGE $RSYNC_HOST:$RSYNC_BASE/indb/src/ .

        #sync INDB binaries, libraries & files
        mkdir -p $BASE/indb
        cd $BASE/indb
        $RSYNC $RSYNC_REPLACE $RSYNC_HOST:$RSYNC_BASE/indb/{bin,lib,perllib,tools,util,xbin} .
        )
    }
    FUNC_HELP+=("rsyncINDB\t\t$D")

    D="Run rsync and pull changes to INDB/util in from $RSYNC_HOST"
    rsyncINDButil() {
        (
		BASE=$BASE/app/stow/built

        #suppress directory notes
        SHUSH=1

        #sync sources
        mkdir -p $BASE/src
        cd $BASE/src
        $RSYNC $RSYNC_MERGE $RSYNC_HOST:$RSYNC_BASE/indb/src/ .

        #sync INDB binaries, libraries & files
        mkdir -p $BASE/indb
        cd $BASE/indb
        $RSYNC $RSYNC_REPLACE $RSYNC_HOST:$RSYNC_BASE/indb/util .
        )
    }
    FUNC_HELP+=("rsyncINDButil\t\t$D")

    D="Run rsync and pull changes to Force from $RSYNC_HOST"
    rsyncForce() {
        (
		BASE=$BASE/app/stow/built

        #suppress directory notes
        SHUSH=1

        #sync sources
        mkdir -p $BASE/src
        cd $BASE/src
        $RSYNC $RSYNC_MERGE $RSYNC_HOST:$RSYNC_BASE/force/src/ .

        #sync Force binaries, libraries & files
        mkdir -p $BASE/force
        cd $BASE/force
        $RSYNC $RSYNC_REPLACE $RSYNC_HOST:$RSYNC_BASE/force/{bin,perllib,prt,rpt,tools,util,xbin,xsl} .
        )
    }
    FUNC_HELP+=("rsyncForce\t\t$D")

    D="Run rsync and pull all changes from $RSYNC_HOST"
    rsyncSds() {
        rsyncINDB
        rsyncForce
    }
    FUNC_HELP+=("rsyncSds\t\t$D")

    D="Follow CTSTATUS.FCS while stripping timestamps"
    ctstatusTail() {
        STATUS=
        if [[ -f $CTREEDATA/CTSTATUS.FCS ]]; then
            STATUS=$CTREEDATA/CTSTATUS.FCS
        elif [[ -f $CTREESERVERDIR/CTSTATUS.FCS ]]; then
            STATUS=$CTREESERVERDIR/CTSTATUS.FCS
        fi
        tail -n 40 -f $STATUS | sed -e '/^[SMTWF][auoehr]/d'
    }
    FUNC_HELP+=("ctstatusTail\t\t$D")

    D="Run isql, but save typing"
    sqli() {
        isql -u ADMIN -a ADMIN $FORCEDLIST:t:r
    }
    FUNC_HELP+=("sqli\t\t$D")

	D="dbdump tables and delete outputs which contain 0 rows"
	coolDump() {
		if [[ -z "$1" ]]; then
			echo "Please provide at least one tablename to dump"
			return 1
		fi
		until [[ -z "$1" ]]; do
			echo -n "Dumping $1..."
		local RES
			RES=$(dbdump $1 2>&1 >$1.txt | \grep records)

			#trim down stderr until we're left with the count of tables dumped
			RES=${RES##*}
			RES=${RES%% *}

			if [[ 0 = $RES ]]; then
				\rm -f $1.txt
				echo -e "\tEmpty"
			elif [[ -z "$RES" ]]; then
				\rm -f $1.txt
				echo -e "\tNon-existent table"
			else
				echo -e "\tDumped"
			fi
			shift
		done
		}
	FUNC_HELP+=("coolDump([TAB ...])\t$D")

    if [[ $(uname) = 'AIX' ]]; then
        D="get the PID of a process P"
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
        FUNC_HELP+=("pgrep(P)\t\t$D")
    fi

    D="Stop Tomcat and Interfaces-Server in one go"
    stopTomcat() {
        for D in $CATALINA_HOME/../interfaces-server/bin $CATALINA_HOME/bin ; do
                if [[ -d $D ]]; then
                        ( cd $D; ./shutdown.sh )
                fi
        done
    }
	FUNC_HELP+=("stopTomcat\t\t$D")

    D="Start Tomcat and Interfaces-Server in one go"
    startTomcat() {
        for D in $CATALINA_HOME/bin $CATALINA_HOME/../interfaces-server/bin ; do
                if [[ -d $D ]]; then
                        ( cd $D; ./startup.sh )
                fi
        done
    }
	FUNC_HELP+=("startTomcat\t\t$D")

	D="restart Tomcat and Interfaces-Server"
	restartTomcat() {
		stopTomcat
		startTomcat
	}
	FUNC_HELP+=("restartTomcat\t\t$D")

	D="stop ctreesql server"
	stopCtree() {
		local OLDPID
		OLDPID=$(pgrep ctreesql)

		#shut down the server
		ctsrvutil -s || echo

		#wait until its down
        print -n Waiting for process $OLDPID to exit
		while pgrep ctreesql >/dev/null 2>&1; do
			print -n .
			sleep 2
		done
		print "\nctreesql has stopped"
	}
	FUNC_HELP+=("stopCtree\t\t$D")

	D="start ctreesql server"
	startCtree() {
		echo Starting the server...
		(
			cd $CTREESERVERDIR
			until ps -e | grep -q [c]treesql; do
				sleep 2
				sc ./Run.Me.To.Start.Ctree.Server
			done
			until ctsrvutil -i &>/dev/null; do sleep 2; done

			echo Started
		)
	}
	FUNC_HELP+=("startCtree\t\t$D")

	D="restart ctreesql server"
	restartCtree() {
		stopCtree
		startCtree
	}
	FUNC_HELP+=("restartCtree\t\t$D")

	help() {
		#builtin help; echo
		print The following convenience functions are defined:
	    print ------------------------------------------------
		for i in "${FUNC_HELP[@]}"; do
			print $i
		done
		echo
	}

    # Given a PID, attach GDB to that process
	attach() {
		if [[ -z "$1" ]]; then
			print  "I need a PID to attach to, son" >&2
			return
		fi

		if [[ ! -d /proc/$1 ]]; then
			print "'$1' isn't a directory under /proc, son" >&2
			return
		fi
        case $(uname) in
            Linux)
                gdb $(readlink /proc/$1/exe) $1 ;;
            AIX)
                gdb /proc/$1/object/a.out $1 ;;
            *)
                print "I don't know how to attach gdb to a PID in this OS" ;;
        esac
	}

	unset D
	LANG=C

    _KEEP_FUNCTIONS=(die)
	# Print a useful message to remind the user what to do next
	>&1 <<MESSAGE
Type 'help' for a list of helper functions defined in this environment

MESSAGE
}

#
# Tie it all together
source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
