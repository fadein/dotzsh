#!/usr/local/bin/zsh

PURPOSE="Spillman Loadtest Zsh task"
VERSION="1.0"
   DATE="Fri Jan 25 12:53:20 CST 2013"
 AUTHOR="Erik Falor © 2013"

#
# Don't change this assignment - it is very important
# The name of this task shall be the name of this script, minus .zsh
TASKNAME=$0:t:r

# Report on time spent on this task
cleanup() {

	# translate seconds into a timestamp "HH:MM:SS"
	prettySeconds() {
		local seconds=$1
		local -a backwards
		local i=1

		#convert raw seconds into array=(seconds minutes hours)
		while [[ $seconds -ne 0 ]]; do
			backwards[$i]=$(( $seconds % 60 ))
			let i++ 
			let seconds=$(( $seconds / 60))
		done

		#reverse the array
		local j=1
		[[ $i -gt 0 ]] && let i--
		local -a result
		while [[ $i -gt 1 ]]; do
			result[$j]=${backwards[$i]}
			let j++
			let i--
		done
		result[$j]=${backwards[$i]}

		#print it out
		case $#result in
			3) printf '%02d:%02d:%02d' ${result[@]} ;;
			2) printf '%02d:%02d' ${result[@]} ;;
			1) printf '00:%02d' ${result[@]} ;;
		esac
	}

	echo You hacked on that for $( prettySeconds $SECONDS )
}

# how do you want to start your shell
spawn() {
    #
    # I like to refer to programs by absolute path for security.  You
    # can do this too, or not.
    SPILLMAN=/usr/local/bin/spillman

	TASK=$TASKNAME $SPILLMAN -h -s $ZSH
}


# Add functions to this environment
env() {
	cd /loadtest

	# GLOBAL DATA
	DATDIR=/localsds/dbs/development-6-2.dbs

    #ALIASES
    alias isql='isql -u ADMIN -a ADMIN'

	# GLOBAL FOR HELP FUNCTION
	FUNC_HELP=()

    # Little functions
	pause() { read -p "Press [Enter] to continue "; }

	# Function descriptions
	D=

	D="grep process table for by process name"
    unalias pgrep
	pgrep() {
		if [[ -z "$1" ]] ; then
			echo Please supply a process name
			return 65
		fi
		ps axww | \grep "[${1:0:1}]${1:1}"
	}
	FUNC_HELP+=("pgrep\t\t\t$D")

    D="Follow CTSTATUS.FCS while stripping timestamps"
    ctstatusTail() {
        tail -n 40 -f $CTREEDATA/CTSTATUS.FCS | sed -e '/^[SMTWF][auoehr]/d'
    }
    FUNC_HELP+=("ctstatusTail\t\t$D")

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

	D="dump and load all tables in the DATDIR"
	reloadTabs() {
		#make sure ctree is up before continuing
		if ! ps -e | grep -q [c]treesql; then
			echo "CtreeServer isn't running!  Run startCtree to get it going"
			return 1
		fi

		(
			cd $DATDIR

			BAKDIR=$(dirname $PWD)/$(basename $PWD).$$.bak
			echo -e "\nBacking up important tables to $BAKDIR"
			mkdir -p $BAKDIR || return 1
			for T in sydtabs syitabs syschema sydoffs syparam apparam sypriv \
				syscrvar syscrprm sypgm symenu symodule; do
				dattool -C $BAKDIR $T.dat
			done

			echo -e "\nDumping all tables in PWD to text"
			for D in *.dat; do
				coolDump ${D%.dat}
			done

			echo -e "\nDeleting all tables in PWD"
			dattool -aD 

			echo -e "\nPrepending $BAKDIR to FORCEDLIST"
			OLDFDL=$FORCEDLIST
			FORCEDLIST=$BAKDIR:$FORCEDLIST

			echo -e "\nRe-creating all tables in PWD from backed-up schema"
			dattool -ac

			echo -e "\nRestoring original FORCEDLIST"
			FORCEDLIST=$OLDFDL

			echo -e "\nBootstrapping the database"
			for T in apnames sypriv sypgm; do
				$INDBDIR/tools/bootstrap_dbload $T.txt $T \
					&& mv $T.txt $T.txt.loaded
			done

			echo -e "\nReloading database"
		echo "do this manually for now - I was running into some funky stuff before"
		echo "to do this right, I'll need to not rely on dbload's exit code, but rather"
		echo "parse the line of stderr that says how many rows were added :("

		\rm -f sy{schema,{d,i}tabs}.txt
			for T in *.txt; do
				dbload -q $T ${T%.txt} #One to throw away... wtf?
				dbload -q $T ${T%.txt} && \
			( cd /localsds/dbs/live.dbs; dattool -i ${T%.txt}; )
		    echo
		done

			#for T in *.txt; do
			#	echo
			#	I=1
			#	OPTS=-q

			#	#for some reason, the first dbload -q will fail, but the 2nd will succeed
			#	#and I will get cterror=12 on the sy tables that I backed-up above
			#	#but some of them I can manually come back and repair...
			#	until dbload $OPTS $T ${T%.txt}; do
			#		let I=I+1
			#		[[ $I -gt 10 ]] && break
			#		echo -e "\nenjoining trial $I of dbloading $T monmentarily..."
			#		sleep 1
			#	done
			#	[[ $I -le 10 ]] && mv $T $T.loaded
			#done

			echo "Be sure to clean up $BAKDIR when you're sure this works!"
			echo "any remaining .loaded files indicate trouble!"
		)
	}
	FUNC_HELP+=("reloadTabs\t\t$D")

	D="add timestamped note to .notes file"
	note() {
		echo >> .notes
		echo "$(\date +%D\ %T): $@" >> .notes
	}
	FUNC_HELP+=("note\t\t\t$D")

	D="get the PID of a process P"
	getpid() {
		if [[ -z "$1" ]] ; then
			echo Please supply a process name
			return 65
		fi
	    local PROC
		PROC=$1
	    local PID
		PID=$(ps -e | \grep "[${PROC:0:1}]${PROC:1}" | cut -c2-9 | tail -n1)
		[[ -n "$PID" ]] && echo $PID
	}
	FUNC_HELP+=("getpid(P)\t\t$D")

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
	restartCtree() {
		stopTomcat
		startTomcat
	}
	FUNC_HELP+=("restartTomcat\t\t$D")

	D="stop ctreesql server"
	stopCtree() {
		local OLDPID
		OLDPID=$(getpid ctreesql)

		#shut down the server
		ctsrvutil -s || echo

		#wait until its down
        print -n Waiting for process $OLDPID to exit
		while getpid ctreesql >/dev/null 2>&1; do
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
			cd /localsds/ctree
			until ps -e | grep -q [c]treesql; do
				sleep 2
				./Run.Me.To.Start.Ctree.Server
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

	D="delete sycad, syunit, cdunit and rlmain from server"
	delTabs() {
		(
		TABLES=(cdcall cdhist cdunit rlmain sycad syunit lwmain)
			cd $DATDIR

			#destroy and then rebuild the tables
			for O in -D -c; do
				echo dattool $O $TABLES
				dattool $O $TABLES
			done
		)
	}
	FUNC_HELP+=("delTabs\t\t\t$D")

	D="dbload all \*.txt files in /loadtest"
	loadTabs() {
		(
		SHUSH=1
			cd /loadtest
			for T in *.txt; do
				dbload -q $T ${T%.txt}
				dbload -q $T ${T%.txt} && \
			( cd /localsds/dbs/live.dbs; dattool -i ${T%.txt}; )
			done
		)
	}
	FUNC_HELP+=("loadTabs\t\t$D")

	D="blow away tables"
	blow() {
		restartCtree

		delTabs

		#reload the tables in one shooting match
		loadTabs
	}
	FUNC_HELP+=("blow\t\t\t$D")

	D="procstack ctreesql (or other proc) every 30 (or so) seconds"
	sample() {
		local PROC
	    PROC=ctreesql
		local SEC
		SEC=30
		[[ -n "$1" ]] && PROC=$1
		[[ -n "$2" ]] && SEC=$2

		echo "Sampling $PROC every $SEC seconds"
		
		while true; do
			local PID
			PID=$(getpid $PROC)
			local SAMPLE
			SAMPLE=${PROC}_$SECONDS.stack
			echo "Taking sample $SAMPLE"
			procstack $PID &>$SAMPLE
			sleep $SEC
		done
	}
	FUNC_HELP+=("sample([P,[S]])\t\t$D")

	help() {
		#builtin help; echo
		print The following convenience functions are defined:
	    print ------------------------------------------------
		for i in "${FUNC_HELP[@]}"; do
			print $i
		done
		echo
	}

	unset D
}

#
# Tie it all together
source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
