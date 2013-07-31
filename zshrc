# fadein's zshrc

[[ -r ~/.dir_colors ]] && eval "$(dircolors ~/.dir_colors -b)"

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %l: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle :compinstall filename '/home/fadein/.zshrc'

# enable cache for the completions
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

setopt pushd_ignore_dups \
    pushd_to_home        \
    hist_ignore_space    \
    hist_save_no_dups    \
    auto_continue        \
    long_list_jobs       \
    hist_ignore_dups     \
    hist_no_store        \
    append_history       \
    auto_cd              \
    extended_glob        \
    notify no_beep       \
    cd_able_vars         \
    multios              \
    brace_ccl            # expand {a-d} into "a b c d"

autoload zmv zargs zcalc

# enable edit-command-line functionality FTW
autoload -U edit-command-line && zle -N edit-command-line

bindkey -e
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
#TODO: checkout ~/build/Documentation/zsh/zshrc_mikachu for more functions to glean...
[[ -r ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

#
# Global environment variables
#
HISTFILE=~/.zsh/history
HISTSIZE=1337
SAVEHIST=1337

#
# Add to fpath, PATH, MANPATH; cull out duplicates
#
for D in ~/.zsh/Completion ~/.zsh/Functions; do
    [[ -d $D ]] && fpath+=$D:a
done
for D in /usr/sbin ~/scripts ~/.zsh ~/.zsh/tasks; do
    [[ -d $D ]] && PATH+=:$D:a
done
for D in /var/lib/share/man /opt/cam/man /opt/csm/man /opt/freeware/man; do
    [[ -d $D ]] && MANPATH+=:$D
done
export PATH MANPATH
if declare -F uniquify >/dev/null; then
    #remove duplicate entries from PATH, MANPATH
    [[ -n $PATH    ]] && PATH=$(uniquify $PATH)
    [[ -n $MANPATH ]] && MANPATH=$(uniquify $MANPATH)
fi

autoload -U compinit; compinit -d ~/.zsh/compdump

#
# Set my cool, cool prompt
#
source ~/.zsh/prompts.zsh screen

#
# Chose a search engine based on what day of the year it is if that gets
# boring, change the %j below to %s for seconds since epoch
sengines=(https://ixquick.com/ https://duckduckgo.com/)
zmodload zsh/datetime
#add one because zsh arrays are 1-indexed
export WWW_HOME=$sengines[$(( $(strftime %j $EPOCHSECONDS) % ${#sengines} + 1))]
unset sengines

#
# User-specific aliases
#
alias cp='cp -i'
alias ctags='ctags --fields=+iaS --extra=+fq'
alias curl='curl -A "Mozilla/4.0"'
alias date='date +"%a, %b %e %Y  %r %Z"'
alias df='df -h'
alias du='du -h'
alias free='free -m'
alias grep='grep -n --color=auto'
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
alias which="which -p"
alias topu="top -u $USER"

#
# because I can't spell...
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

#
# suffix aliases
#
alias -s txt=vim
alias -s conf=vim
alias -s com=lynx
alias -s org=lynx
alias -s net=lynx

#
# Load custom stuff from local zshrc
#
[[ -f ".$(hostname).zshrc" ]] && source ".$(hostname).zshrc"

#this snippet is required in your zshrc for TASKS
[[ -n "$TASK" && -x ~/.zsh/tasks/$TASK.zsh ]] \
    && source ~/.zsh/tasks/$TASK.zsh $TASK \
    || true

# vim:set expandtab foldmethod=indent:
