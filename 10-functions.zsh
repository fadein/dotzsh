# vim: set ft=zsh expandtab:


#TODO: see about making these functions autoloadable
#TODO: checkout ~/build/Documentation/zsh/zshrc_mikachu for more functions to glean...

# enable edit-command-line functionality
autoload -U edit-command-line && zle -N edit-command-line

# other misc. helpful functions
autoload zmv zargs zcalc


# Simple recycle bin implementation.  Moves files into $RECYCLE, after which they are deleted after a few days.
# Relies on realpath(1) to preserve file's original path name
#
# Works in conjunction with this crontab snippet:
#
RECYCLE=~/.recycle
RECYCLE_DAYS=30
# Take out the trash every 2 hours
# 00 */2   *   *  *          find $RECYCLE -mindepth 1 -ctime +$RECYCLE_DAYS -exec rm -rf '{}' +

recycle() {
    if (( $# < 1 )); then
        print Usage: recycle FILE_OR_DIR...
    else
        if [[ ! -d $RECYCLE ]]; then
            print Creating recycle bin $RECYCLE
            if ! mkdir $RECYCLE; then
                print Failed to create recycle bin $RECYCLE
                return 1
            fi
        fi
        local SUCCESS=0
        until (( $# < 1 )); do

            if [[ -e $1 ]]; then
                # preserve this file's original path name
                local DEST=$(realpath $1)
                DEST=$RECYCLE/${DEST//\//:}

                # Append a suffix in case there is already a file in the recycle bin with this name
                local I=0 TRY=$DEST
                while [[ -e $TRY ]]; do
                    TRY=$DEST.$(( I++ ))
                done
                DEST=$TRY

                print "Recycling '$1' as '$DEST'..."

                if mv $1 $DEST; then
                    (( SUCCESS++ ))
                fi

            else
                print "'$1' doesn't exist"
            fi

            shift
        done

        if (( SUCCESS == 1 )); then
            print This file will be deleted in $RECYCLE_DAYS days
        elif (( SUCCESS > 1 )); then
            print These files will be deleted in $RECYCLE_DAYS days
        fi
    fi
}


# ding is a command-modifier, much like `time` or `sudo`
# Ring the bell once when the supplied command succeeds, thrice when it has failed
# The command's own exit code is returned to the shell
ding() {
    # run the supplied command, preserving its return code
    eval $@
    local retval=$?

    if [[ $retval == 0 ]]; then
        echo -e "\a"
    else
        for ding in {0..2}; do
            echo -ne "\a"; sleep 1
        done
    fi

    return $retval
}


# remove duplicate entries from colon separated string while preserving order
uniquify() {
    local IFS=:
    local -a OUT_A
    local i j
    for i in "${=1}"; do
        local in=
        for j in "${=OUT_A}"; do
            if [[ "$i" = "$j" ]]; then
                in=1
                break
            fi
        done
        if [[ -z "$in" ]]; then
            OUT_A+=($i)
        fi
    done
    echo "$OUT_A"
}

# this little gem lets me say .. .. .. to go back three directories
..() {
	#join given arguments with / and run the builtin "cd" once
	#so as not to screw up "cd -"
	local IFS=/
	#TODO: could the -q argument to cd be useful to keep things quiet here?
	cd "../$*"
}

#this provides completion to my sweet .. command
#TODO: this is broken because it looks for dirs relative to the CWD
_dotdotcomp() {
	local DST=.

	#build the dest string
	local i=0
	local IFS=$'\n'
	for ((i=1; $i < ${#COMP_WORDS[@]}-1; i+=1)); do
		DST="$DST/${COMP_WORDS[$i]}"
	done

	# eval to counteract the possible backslashes in $DST
	COMPREPLY=( $(eval builtin cd ../$DST; compgen -o nospace -d ${COMP_WORDS[$COMP_CWORD]}) )

	return 0
}

# -o filenames tells complete to backslash escape certain chars in
# some directory/filenames
#TODO: port this to zsh
#complete -o filenames -F _dotdotcomp ..


# this hook function decides which commands are added to the shell's history
zshaddhistory() {
    emulate -L zsh
    [[ ! $1 =~ '^(fg|bg)\s*$' ]]
}


# go out and get my IP address
whatismyipaddress() {
	curl http://checkip.dyndns.org 2>/dev/null | command grep -o -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
}


# geolocate an ip address with cURL and the ip-api.com service
iplocate() {
    if (( $# < 1 )); then
        curl -s http://ip-api.com/json/ | python3 -m json.tool
    else
        until [[ $# < 1 ]]; do
            curl -s http://ip-api.com/json/$1 | python3 -m json.tool
            shift
        done
    fi
}


urxvtbg() {
    if [[ $# -lt 1 ]]; then
        print "Usage: urxvtbg color [TTY]"
        print "Defaults to changing color of current tty"
        return 1
    fi

    if [[ $# -gt 1 ]]; then
        #print changing color of $2 to $1
        if [[ ${2:0:5} == '/dev/' ]]; then
            print "\x1b]11;$1\x07" > $2
        else
            print "\x1b]11;$1\x07" > /dev/$2
        fi
    else
        #print changing color of current terminal to $1
        print "\x1b]11;$1\x07"
    fi
}


# countdown is a command-modifier, much like `time` or `sudo`
# Print a dramatic countdown timer before running a command
countdown() {
    if [[ $# -lt 1 ]]; then
        echo 'Usage: countdown SECONDS [CMD ARGS]'
        return 1
    fi

    local N I
    N=$1
    I=1
    shift
    [[ $# -ge 1 ]] && echo "Running '$@' in "

    until [[ $N -eq 0 ]]; do
        if [[ $((I % 10)) -eq 0 ]]; then
            echo "$N... "
        else
            echo -n "$N... "
        fi

        sleep 1
        ((N--, I++))
    done
    echo Done

    if [[ $# -ge 1 ]]; then
        eval $@
    fi
}


# Display directory notes
# When passed a filename as an argument, link that file to the name .notes
notes() {
    if [[ $# != 0 ]]; then
        ln -fs $1 .notes
    fi

    [[ -r .notes && -z "$SHUSH" ]] && { fmt -${COLUMNS:-80} -s .notes; echo; }
}

# if entering a directory with a special .notes file echo its contents
[[ 0 == ${+chpwd_functions} || 0 == $chpwd_functions[(I)notes] ]] \
	&& chpwd_functions+=(notes)


# Swap the contents of two files
swap() {
	if [ -z "$1" -o -z "$2" ]; then
		echo Usage: swap file1 file2
		echo Swaps the contents of file1 with file2
		return
	fi

	if [ ! -r $1 -a ! -w $1 ]; then
		echo No permission to move $1
		return
	fi
	if [ ! -r $2 -a ! -w $2 ]; then
		echo No permission to move $2
		return
	fi

	RANDFILENAME=${RANDOM}${$}

	mv -f $1 $RANDFILENAME
	mv -f $2 $1
	mv -f $RANDFILENAME $2
}

undosubdirs() {
	if [ -z $1 ]
	then
		for dir in *
		do
			echo Really undo $dir \(y/n\)\?
			read yn
			if [ $yn = "y" ]; then
				mv -i $dir/* .
				rmdir $dir
			fi
		done
	else
		mv -i $1/* .
		rmdir $1
	fi
}


# Make and chdir into a new directory DIRNAME
mcdir() {
	if [ -z "$1" ]; then
		echo Usage: mcdir DIRNAME
		echo Make and change into DIRNAME
		return
	fi
	if [[ ! -d "$1" ]]; then
		mkdir -p "$1"
	fi
	cd "$1"
}


# report on the amount of entropy in the system
entropy() {
	local AVAIL=$(cat /proc/sys/kernel/random/entropy_avail)
	local PSIZE=$(cat /proc/sys/kernel/random/poolsize)
	printf "(%d/%d) %.2f%%\n" $AVAIL $PSIZE $(( $AVAIL / $PSIZE.0 * 100 ))
}

sec2time() {
    while [ $# -gt 0 ]; do
        TZ=GMT perl -e "print scalar localtime $1, \" GMT\n\""
        TZ=MST perl -e "print scalar localtime $1, \" MST\n\""
        echo
        shift
    done
}

# re-source this file
#TODO: port this to zsh
#eval "function reload() { source ${BASH_ARGV[0]}; }"

# Split an environment variable on a delimiter (default ':')
# and return the nth item
nth () {
	if [ "$#" -lt 2 ]; then
		echo Too few arguments to nth: "$*";
		echo Usage: nth \<position\> \<list\> \<delimiter\>;
		return 65;
	fi;
	local PATHS=$2
	local DELIMIT=${3-":"};
	if [ "0" = `expr index $PATHS $DELIMIT` ]; then
		PATHS=$(eval echo \$$PATHS)
	fi
	echo $PATHS | cut -d$DELIMIT -f$1
}

# aliases using nth
alias first='nth 1'
alias second='nth 2'
alias third='nth 3'
alias fourth='nth 4'
alias fifth='nth 5'
alias sixth='nth 6'
alias seventh='nth 7'
alias eighth='nth 8'
alias ninth='nth 9'
alias tenth='nth 10'
alias 1st='nth 1'
alias 2nd='nth 2'
alias 3rd='nth 3'
alias 4th='nth 4'
alias 5th='nth 5'
alias 6th='nth 6'
alias 7th='nth 7'
alias 8th='nth 8'
alias 9th='nth 9'
alias 10th='nth 10'

# turn off history recording
offtherecord() {
	umask 027
	if [[ -n "$HISTFILE" ]]; then
		OLDHISTFILE=$HISTFILE
		unset HISTFILE
	fi
	if [[ -n "$HISTSIZE" ]]; then
		OLDHISTSIZE=$HISTSIZE
		HISTSIZE=0
	fi
	[[ -n "$@" ]] && $@ || true
}
alias otr=offtherecord
otx() {
	[[ -n "$@" ]] && otr exec $@
}

# turn on history recording
ontherecord() {
	umask 022
	if [[ -n "$OLDHISTFILE" ]]; then
		HISTFILE=$OLDHISTFILE
		unset OLDHISTFILE
	fi
	if [[ -n "$HISTSIZE" ]]; then
		HISTSIZE=$OLDHISTSIZE
		unset OLDHISTSIZE
	fi
}


# Escalate privileges, Hollywood style
override() {
	eval sudo $(fc -lLn -1)
}


# In case I fatfinger Ctrl-p
p() {
	eval $(fc -lLn -1)
}

# mount a filesystem to a directory and chdir into it
mountc() {
	if [ -z "$1" ]; then
		echo Usage: mountc \<dirname\>
		echo Mount and chdir into directory \<dirname\>
		return
	fi
	mount $1 && cd $1
}


makerepo() {

    case $1 in
        -h | -help | --help)
            cat 1>&2 <<MSG 
Create a remote git repo under /GIT on viking-dyn and push the current directory/repo
If this directory isn't already a repo, create a new repo and commit EVERYTHING here

If a repo name is not given, use the dirname of CWD

Usage: $0 [REPO_NAME]

MSG
            return 1
        ;;
    esac

    # If I'm not already in a git repo, make one here
    if ! git status --porcelain=v1 2>/dev/null; then
        git init
        git add .
        git commit -m "First post"
    fi


    # Ensure that there isn't already a remote named 'origin' here
    if git remote | grep -qw origin; then
        print 1>&2 "Error!  Remote named 'origin' already exists"
        return 3
    fi


    # If the user didn't specify a name for the repo, use the dirname of CWD
    if (( $# >= 1 )); then
        REPO_NAME=$1
    else
        REPO_NAME=$PWD:t
    fi

    if ! ssh viking-dyn "git init --bare --shared=group /GIT/$REPO_NAME.git"; then
        print 1>&2 "Error!  Failed to create the remote repo"
        return 2
    fi


    if ! git remote add origin viking-dyn:/GIT/$REPO_NAME.git; then
        print 1>&2 "Error!  Failed to add remote repo 'origin'"
        return 2
    fi

    if ! git push --all -u origin; then
        print 1>&2 "Error!  Failed to push --all refs to 'origin'"
        return 2
    fi
}


zle -N increase-char _increase_char
zle -N decrease-char _increase_char
bindkey "^[^N"    increase-char
bindkey "^[^P"    decrease-char
_increase_char() {
  local char

  [[ $#BUFFER -le 0 ]] && return

  char=$BUFFER[CURSOR]

  if [[ $WIDGET = increase-char ]]; then
    char=${(#):-$((#char+${NUMERIC:-1}))}
  else
    char=${(#):-$((#char-${NUMERIC:-1}))}
  fi

  BUFFER[CURSOR]=$char
}

zle -N increase-number _increase_number
zle -N decrease-number _increase_number
bindkey "^[^A"    increase-number
bindkey "^[^X"    decrease-number
_increase_number() {
  integer pos NUMBER i first last prelength diff
  pos=$CURSOR

  i=1
  # find numbers starting from the left of the cursor to the end of the line
  while [[ $BUFFER[pos] != [[:digit:]] ]]; do
    (( pos += i ))
    (( $pos > $#BUFFER )) && i=-1
    (( $pos < 0 )) && return
  done

  # use the numeric argument and default to 1
  # negate if called as decrease-number
  NUMBER=${NUMERIC:-1}
  if [[ $WIDGET = decrease-number ]]; then
    (( NUMBER = 0 - $NUMBER ))
  fi

  # find the start of the number
  i=$pos
  while [[ $BUFFER[i-1] = [[:digit:]] ]]; do
    (( i-- ))
  done
  first=$i

  while [[ $BUFFER[i] = 0 ]]; do
    (( i++ ))
  done
  #zeros=$(( i - first ))

  # include one leading - if found
  if [[ $BUFFER[first-1] = - ]]; then
    (( first-- ))
  fi

  # find the end of the number
  i=$pos
  while [[ $BUFFER[i+1] = [[:digit:]] ]]; do
    (( i++ ))
  done
  last=$i

  # change the number and move cursor after it
  prelength=$#BUFFER
  (( BUFFER[first,last] += $NUMBER ))
#  (( diff = $#BUFFER - $prelength ))
#  print -l :: $zeros $diff > /fifo
#  if (( diff < 0 )); then
#    BUFFER[first,first-1]=${(l:zeros+diff::0:):-}
#  fi
  (( diff = $#BUFFER - $prelength ))
  (( CURSOR = last + diff ))
}
