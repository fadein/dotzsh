#!/bin/env zsh

 PURPOSE="Run nmon like a boss"
 VERSION="1.0"
    DATE="Wed Jul 24 13:34:15 MDT 2013"
  AUTHOR="Erik Falor <efalor@spillman.com>"
TASKNAME=$0:t:r

NMON_CMD=/usr/bin/nmon
FUSER_CMD=/usr/sbin/fuser


#
# Instructions to run one time to set up your environment.  You
# could download a file, update a repository, sync a database, etc.
setup() {
    #
    # create a directory in which to store nmon recordings
    local NMONDIR=$HOME/nmon
    if [[ -a $NMONDIR && ! -d $NMONDIR ]]; then
        die "a non-directory named '$NMONDIR' exists"
    elif [[ ! -d $NMONDIR ]] && ! mkdir $NMONDIR; then
        die "couldn't create directory '$NMONDIR'"
    elif ! cd $NMONDIR 2>/dev/null; then
        die "couldn't chdir into '$NMONDIR'"
    fi
}

#
# make sure we're running this on AIX, since Linux doesn't have nmon (I think)
spawn() {
    case $OSTYPE in
        aix*)
            TASK=$TASKNAME $ZSH_NAME ;;
        *)
            die "This task is only meant for AIX hosts" ;;
    esac
}

env() {

    # translate seconds into a timestamp "HH:MM:SS"
    ppTime() {
        local seconds=${1:-$SECONDS}
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


    ongoing() {
        #reset probes hash
        PROBES=()

        # check how long any ongoing probes have been running
        for F in *.nmon; do
            P=${(z)$(fuser $F 2>&1 | cut -d: -f2)}
            if [[ $P =~ [0-9] ]]; then
                # check the ages of active .nmon files in cwd
                print "Probe $F($P) has been running for $( ppTime $(( $EPOCHSECONDS - $(strftime -r $PROBE_FMT $F ) )) )"
                PROBES[$F]=$P
            fi
        done
    }

    #
    # start a new nmon probe
    probe() {
        local PROBE_NAME=$(strftime $PROBE_FMT $EPOCHSECONDS)
        print "Starting probe $PROBE_NAME..."
        $NMON_CMD -$NMON_OPTS -F $PROBE_NAME

        #TODO: can I do this more elegantly?  like maybe count fuser PIDs of this probe in
        #      an until loop?
        sleep 10
        ongoing
        #print "Run 'ongoing' after a few seconds to update the table of running probes"
    }

    #
    # show all active probes
    probes() {
        if [[ $#PROBES > 0 ]]; then 
            print "\nActive probes:"
            for P in ${(k)PROBES}; do
                print "\t$P"
            done
        fi
    }

    #
    # stop a running probe
    stopProbe() {
        if [[ -n "$PROBES[$1]" ]]; then 
            print "stopping probe $1..."
            while kill -SIGUSR2 $PROBES[$1] 2>/dev/null; do
                :
            done
            ongoing
        else
            print "There is no running probe named '$1'"
        fi
    }

    #
	# Remind of running probes before each prompt
    [[ 0 == ${+precmd_functions} || 0 == $precmd_functions[(I)probes] ]] \
        && precmd_functions+=(probes)

    # command-line options to nmon
    :<<FLAGS_MEANING
    f = spreadsheet output format
    M = include MEMPAGES section
    P = include paging space section
    V = include disk volume group section
    J = skip JFS sections
    Y = track top processes & args : sum their totals together if same name
    d = include disk service time sections
    p = print pid of recorder
    m [dir] = chdir into dir before saving data to a file
FLAGS_MEANING
    NMON_OPTS=MPVJYdp
    typeset -g -A PROBES
    PROBE_FMT=$(hostname)_%m_%d_%Y_%H_%M.nmon

    ongoing
}

cleanup() {
	print "You nmon'd that for $( prettySeconds $SECONDS )"
}

#
# Tie it all together
source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
