# fadein's zshrc

[[ -r ~/.dir_colors ]] && eval "$(dircolors ~/.dir_colors -b)"

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %l: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' accept-exact '*(N)'
zstyle :compinstall filename '/home/pi/.zshrc'

# enable cache for the completions
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zshcache

HISTFILE=~/.zhistory
HISTSIZE=1337
SAVEHIST=1337
bindkey -e

autoload -U compinit; compinit

setopt pushd_ignore_dups \
    pushd_to_home \
    hist_ignore_space \
    hist_save_no_dups \
    auto_continue \
    long_list_jobs \
    hist_ignore_dups \
    hist_no_store \
    append_history \
    auto_cd \
    extended_glob \
    notify no_beep \
    cd_able_vars

autoload zmv zargs zcalc

# enable edit-command-line functionality FTW
autoload -U edit-command-line && zle -N edit-command-line
bindkey "\C-X\C-E" edit-command-line

#fix "delete emits a ~"
bindkey "^[[3~"   delete-char
bindkey "^[[3;2~" delete-char
bindkey "^[[3$"   delete-char

# Insert command line to quickly eval an empty scheme expression with the chicken interpreter
bindkey -s "\es" "\C-acsi -p '\C-e'\C-b"

# enable esc-p command search, which completes on the beginning of the line
# typed so far
set ESC-P

# stop background jobs that try to write to the terminal
#stty tostop 

# enable ctrl-s
stty -ixon

#
# User-specific environment settings
#
ulimit -c unlimited

#source cool functions; needed for uniquify
#TODO: see about making these functions autoloadable
source ~/.zsh/functions.zsh

#remove duplicate entries from PATH
export PATH=$PATH:/usr/sbin:$HOME/.zsh/tasks:$HOME/scripts
if declare -F uniquify >/dev/null; then
    [[ -n "$PATH" ]] && PATH=$(uniquify $PATH)
fi

#set my cool, cool prompt
source ~/.zsh/prompts.zsh screen

#set up escapepod
if [[ -f  ~/scripts/escapepod.sh ]]; then
    source ~/scripts/escapepod.sh
    ESCAPEPOD_FILES=".abook/ .bashrc .config/newsbeuter .config/htop .csirc .git* .gnupg/
    .htoprc .irssi/ .lynx* .mailcap .mc/ .mime.types .mutt/ .muttrc .newsbeuter/ .notes
    .profile .redeclipse/serv* .screenrc .sig .ssh/ .toprc .vimrc .zshrc .zsh/ scripts/"
    ESCAPEPOD_EXCLUDES="scripts/.git/* .zsh/*/.git/*"
fi

#setup ssh-agent
#source ssh-agent-startup.sh

# Exit MidnightCommander into its last CWD:
#source /usr/libexec/mc/mc.sh

#
# Global environment variables
#
export GPG_TTY=$(tty)
export BROWSER=/usr/bin/lynx
export COWPATH=/usr/share/cows
export EDIT=/usr/bin/vim
export EDITOR=/usr/bin/vim
export GREP_COLOR="02;41"   #red back, white fore
export LYNX_CFG=~/.lynx.cfg
export MAILDIR=~/.maildir
export NNTPSERVER=nntp.aioe.org

#chose a search engine based on what day of the year it is
#if that gets boring, change the %j below to %s for seconds since epoch
sengines=(https://ixquick.com/ https://duckduckgo.com/)
zmodload zsh/datetime
#add one because zsh arrays are 1-indexed: WTF?
export WWW_HOME=$sengines[$(( $(strftime %j $EPOCHSECONDS) % ${#sengines} + 1))]
unset sengines

#
#User-specific aliases
#
alias apg='apg -MNCL -m 8'
alias cp='cp -i'
alias csi='csi -q'
alias ctags='ctags --fields=+iaS --extra=+fq'
alias curl='curl -A "Mozilla/4.0"'
alias date='date +"%a, %b %e %Y  %r %Z"'
alias df='df -h'
alias du='du -h'
alias entropy=cat\ /proc/sys/kernel/random/entropy_avail
alias free='free -m'
alias grep='grep --color=auto'
alias l='ls --color=auto -F'
alias la='ls --color=auto -Fa'
alias ll='ls --color=auto -Flh'
alias lla='ls --color=auto -Flha'
alias lld='ls --color=auto -Flhd'
alias ls='ls --color=auto -F'
alias lsd='ls --color=auto -Fd'
alias lt='ls --color=auto --full-time -Ft'
alias lynx='lynx -use_mouse'
alias mc='export TERM=xterm; mc -a'
alias mv='mv -i'
alias niceme='renice -n 10 -p $$'
alias nl='nl -ba'
alias pd='pushd'
alias pgrep='pgrep -l'
alias pwd='pwd -P'
alias rm='rm -i'
alias shred='shred -uz'
alias topu="htop -u $USER"
alias which="which -p"

#
#because I can't spell...
#
alias grpe=grep
alias les=less
alias lss=less
alias mor=more
alias mroe=more
alias jods='jobs'
alias sls=ls
alias scd='cd'
alias fiel=file

#
# vi commands
#
alias :close='echo Cannot close last window'
alias :e='vim'
alias :q!='exit'
alias :q='exit'
alias :qa='exit'
alias :r='<'
alias :w="echo Th15 1Sn\'7 vi, 5Uc\|\<4\!"
alias :wq='exit'
alias :x='exit'

#
# 1337 h4X0r 4L14535
#
alias bye='exit'
alias copy='cp -i'
alias del='rm -i'
alias deltree='rm -rf'
alias move='mv -i'
alias screen-r=screen\ -r
alias screenr=screen\ -r

#this snippet is required in your zshrc for TASKS
[[ -n "$TASK" && -x ~/.zsh/tasks/$TASK.zsh ]] \
	&& source ~/.zsh/tasks/$TASK.zsh $TASK \
    || true

# vim:set expandtab foldmethod=indent:
