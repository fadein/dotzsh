bindkey -e
bindkey "\C-X\C-E" edit-command-line

#fix "delete emits a ~"
bindkey "^[[3~"   delete-char
bindkey "^[[3;2~" delete-char
bindkey "^[[3$"   delete-char

# Insert command line to quickly eval an empty scheme expression with the chicken interpreter
bindkey -s "\es" "\C-acsi -p '\C-e'\C-b"


# Remove binding to Ctrl-D (default is delete-char-or-list)
# Aesthetic improvement in lectures where stty(1) disables Ctrl-D's EOF meaning
bindkey -r "\C-D"


# A user-defined ZLE widget that toggles `sudo` or `sudoedit` in front
# of the current (or previous) command
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    elif [[ $BUFFER == $EDITOR:t\ * ]]; then
        LBUFFER="${LBUFFER#$EDITOR:t }"
        LBUFFER="sudoedit $LBUFFER"
    elif [[ $BUFFER == $EDITOR\ * ]]; then
        LBUFFER="${LBUFFER#$EDITOR }"
        LBUFFER="sudoedit $LBUFFER"
    elif [[ $BUFFER == sudoedit\ * ]]; then
        LBUFFER="${LBUFFER#sudoedit }"
        LBUFFER="$EDITOR:t $LBUFFER"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line

# Bind this widget to the keys: [Esc] [Esc]
bindkey "^[^[" sudo-command-line
# bindkey -M vicmd "^[^[" sudo-command-line  # uncomment for vi-mode
