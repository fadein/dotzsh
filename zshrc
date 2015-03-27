# fadein's zshrc

[[ -r ~/.dir_colors ]] && eval "$(dircolors ~/.dir_colors -b)"

[[ -r /etc/zsh/zprofile ]] && source /etc/zsh/zprofile

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

setopt                   \
    append_history       \
    auto_cd              \
    auto_continue        \
    brace_ccl            \
    cd_able_vars         \
    extended_glob        \
    extended_history     \
    hist_ignore_dups     \
    hist_ignore_space    \
    hist_no_store        \
    hist_reduce_blanks   \
    hist_save_no_dups    \
    inc_append_history   \
    long_list_jobs       \
    multios              \
    notify no_beep       \
    pushd_ignore_dups    \
    pushd_to_home        \
    share_history        \
    # end of options

# enable esc-p command search, which completes on the beginning of the line
# typed so far
set ESC-P

autoload -U compinit; compinit -d ~/.zsh/compdump

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

#
# User-specific environment settings
#
ulimit -c unlimited


# stop background jobs that try to write to the terminal
#stty tostop

# enable ctrl-s
stty -ixon

#
# Global environment variables
#
HISTFILE=~/.zsh/history
HISTSIZE=1337
SAVEHIST=1337

#source cool functions; needed for uniquify
#TODO: see about making these functions autoloadable
#TODO: checkout ~/build/Documentation/zsh/zshrc_mikachu for more functions to glean...
[[ -r ~/.zsh/functions.zsh ]] && source ~/.zsh/functions.zsh

#
# Add to PATH, MANPATH, and cull out duplicates
#
for D in /usr/sbin ~/scripts ~/.zsh ~/.zsh/tasks; do
    [[ -d $D ]] && PATH+=:$D
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

#
# Chose a search engine based on what day of the year it is if that gets
# boring, change the %j below to %s for seconds since epoch
sengines=(https://ixquick.com/ https://duckduckgo.com/)
zmodload zsh/datetime
#add one because zsh arrays are 1-indexed
export WWW_HOME=$sengines[$(( $(strftime %j $EPOCHSECONDS) % ${#sengines} + 1))]
unset sengines

#
# Set my cool, cool prompt
#
[[ -r ~/.zsh/prompts.zsh ]] && source ~/.zsh/prompts.zsh screen

#
# Aliases to help save keystrokes, prevent typos
#
[[ -r ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh

#
# Load custom stuff from local zshrc
#
[[ -r ".$(hostname).zshrc" ]] && source ".$(hostname).zshrc"

#
# this snippet is required in your zshrc for TASKS
#
[[ -n "$TASK" && -x ~/.zsh/tasks/$TASK.zsh ]] \
    && source ~/.zsh/tasks/$TASK.zsh $TASK \
    || true

# vim:set expandtab foldmethod=indent:
