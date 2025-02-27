# Prevent corefiles from being truncated
ulimit -c unlimited

# stop background jobs that try to write to the terminal
#stty tostop

# Don't use Ctrl-S for scrollock; enable incremental history searching
stty -ixon

#
# Zsh configuration variables
HISTFILE=~/.zsh/history
HISTSIZE=1337
SAVEHIST=1337


#
# DIR_COLORS for `ls` and other tools
case $OSTYPE in
    darwin*)
        export LSCOLORS=exGxFxdaCxDaDaahadecec
        ;;
    *)
        [[ -r ~/.dircolors ]] && eval "$(dircolors ~/.dircolors -b)"
        ;;
esac


#
# Global environment variables
export PAGER='less -r'
export EDITOR=/usr/bin/vim
export EDIT=$EDITOR
export TMPDIR=/tmp
export TMP=/tmp
export XDG_CONFIG_HOME=~/.config
if [[ -d $HOME/devel/go ]]; then
    export GOPATH=$HOME/devel/go:/usr/share/gocode
else
    export GOPATH=/usr/share/gocode
fi
[[ -d $GOPATH/bin ]] && PATH+=:${GOPATH:A}/bin


#
# less(1) pager configuration, including colorized man pages
# https://www.howtogeek.com/683134/how-to-display-man-pages-in-color-on-linux/
export LESS='--RAW-CONTROL-CHARS --jump-target=3'
export LESS_TERMCAP_md=$'\e[01;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[47;90m'
export LESS_TERMCAP_se=$'\e[0m'


#
# Personal recycle bin - see `fn_util/recycle`
export RECYCLE=~/.recycle
export RECYCLE_DAYS=30


#
# typeset -U constrains these vars to contain only unique elements
# typeset -T ties a colon-separated scalar (uppercase) to a array (lowercase)
typeset -U -g -T PATH path
for D in /usr/local/bin /usr/local/sbin /usr/sbin /sbin ~/.local/bin  ~/.zsh/tasks; do
    [[ -d $D ]] && path=($D:A $path)
done

typeset -U -g -T FPATH fpath
for D in ~/.zsh/functions; do
    [[ -d $D ]] && fpath=($D:A $fpath)
done

typeset -U -g -x -T MANPATH manpath
for D in $HOME/.local/share/man /usr/local/man /usr/local/share/man /usr/man /usr/share/man /var/lib/share/man /opt/freeware/man; do
    [[ -d $D ]] && MANPATH+=:$D:A
done


#
# Chose a search engine based on what day of the year it is if that gets
# boring, change the %j below to %s for seconds since epoch
sengines=(https://ixquick.com/
	https://duckduckgo.com/lite/
	https://yippy.com/
	https://hulbee.com/
	https://search.disconnect.me/
	https://metager.de/en)
zmodload zsh/datetime
#add one because zsh arrays are 1-indexed
export WWW_HOME=$sengines[$(( $(strftime %j $EPOCHSECONDS) % ${#sengines} + 1))]
unset sengines
