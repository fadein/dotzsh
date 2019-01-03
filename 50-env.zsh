# Prevent corefiles from being truncated
ulimit -c unlimited

# stop background jobs that try to write to the terminal
#stty tostop

# Don't use Ctrl-S for scrollock; enable incremental history searching
stty -ixon

# set tabstops at 4 spaces
tabs 4

#
# Zsh configuration variables
HISTFILE=~/.zsh/history
HISTSIZE=1337
SAVEHIST=1337

#
# Global environment variables
export PAGER='less -r'
export LESS='-MFX'
export EDITOR=/usr/bin/vim
export EDIT=$EDITOR

#
# Add to PATH, MANPATH, and cull out duplicates
for D in /usr/sbin ~/bin ~/.zsh ~/.zsh/tasks; do
    [[ -d $D ]] && PATH+=:$D
done
for D in /usr/local/share/man /var/lib/share/man /opt/cam/man /opt/csm/man /opt/freeware/man; do
    [[ -d $D ]] && MANPATH+=:$D
done
export PATH MANPATH
if declare -F uniquify >/dev/null; then
    #remove duplicate entries from PATH, MANPATH
    [[ -n $PATH    ]] && PATH=$(uniquify $PATH)
    [[ -n $MANPATH ]] && MANPATH=$(uniquify $MANPATH)
fi

#
# Chose a search engine based on what day of the year it is if that gets
# boring, change the %j below to %s for seconds since epoch
sengines=(https://ixquick.com/
	https://duckduckgo.com/lite/
	# https://privatelee.com/ # requires JS
	https://yippy.com/
	https://hulbee.com/
	https://search.disconnect.me/
	https://metager.de/en)
zmodload zsh/datetime
#add one because zsh arrays are 1-indexed
export WWW_HOME=$sengines[$(( $(strftime %j $EPOCHSECONDS) % ${#sengines} + 1))]
unset sengines
