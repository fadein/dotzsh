#!/bin/zsh


#TODO: see about making these functions autoloadable
#TODO: checkout ~/build/Documentation/zsh/zshrc_mikachu for more functions to glean...

# enable the completion system
autoload -U compinit; compinit -d ~/.zsh/compdump

# enable edit-command-line functionality
autoload -U edit-command-line && zle -N edit-command-line

# other misc. helpful functions
autoload zmv zargs zcalc

# ding is a command-modifier:
# ring the bell once when the supplied command succeeds, thrice when it has failed
ding() {
    # run the supplied commandline, preserving its return code
    $@
    local retval=$?

    if [[ $retval == 0 ]]; then
        print "\a"
    else
        for (( dings=0; dings < 3; dings++ )) { print -n "\a"; sleep 1 }
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

# this hook function decides which commands are added to the shell's history
zshaddhistory() {
	[[ "$1" =~ '^(fg|bg)\s+$' ]] && return 1
	return 0
}

# -o filenames tells complete to backslash escape certain chars in
# some directory/filenames
#TODO: port this to zsh
#complete -o filenames -F _dotdotcomp ..


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

# Make and chdir into <dirname>
mcdir() {
	if [ -z "$1" ]; then
		echo Usage: mcdir \<dirname\>
		echo Make and change into \<dirname\>
		return
	fi
	if [ ! -d "$1" ]; then
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
	TZ=GMT perl -e "print scalar localtime $1, \" GMT\n\""
	TZ=MST perl -e "print scalar localtime $1, \" MST\n\""
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

# go out and get my IP address
whatismyipaddress() {
	curl http://checkip.dyndns.org 2>/dev/null | command grep -o -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
}


zle -N increase-char _increase_char
zle -N decrease-char _increase_char
bindkey "^[^O"    increase-char
bindkey "^[^E"    decrease-char
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
bindkey "^[^P"    increase-number
bindkey "^[^_"    decrease-number
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

