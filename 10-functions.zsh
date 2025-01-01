# vim: set ft=zsh expandtab:

# autoload misc. Zsh functions
autoload zmv zargs zcalc zrecompile

# Functions using these variables have been moved under fn_school
SEMESTYR=Sp25
BASE=$HOME/school


# Autoload functions
for fndir in \
    ~/.zsh/fn_util    \
    ~/.zsh/fn_gadgets \
    ~/.zsh/fn_linux   \
    ~/.zsh/fn_school  \
    ; do
    [[ ! -d $fndir ]] && continue

    zrecompile -p -M ${fndir}.zwc ${fndir}/*
    # zcompile ${fndir}.zwc ${fndir}/*

    if [[ -f $fndir.zwc ]]; then
        fpath=($fndir.zwc $fpath)
        autoload -Uw $fndir.zwc
    fi
done
unset fndir


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


# This hook function decides which commands are added to the shell's history
# If it returns status 1, the command is not saved in history,
# though it lingers until the next command is run
if [[ $ZSH_VERSION != 5.2 ]]; then
    zshaddhistory() {
        emulate -L zsh
        [[ ! $1 =~ '^(fg|bg)\s*' ]]
        # local res=$?  # debugging
        # print "zshaddhistory($1) => $res"
        # return $res
    }
fi


if functions notes >/dev/null; then
    # if entering a directory with a special .notes file echo its contents
    [[ 0 == ${+chpwd_functions} || 0 == $chpwd_functions[(I)notes] ]] \
        && chpwd_functions+=(notes)
fi


if functions nth >/dev/null; then
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
fi


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
