# fadein's zshrc

[[ -r ~/.dircolors ]] && eval "$(dircolors ~/.dircolors -b)"

# Source global definitions
[[ -r /etc/zsh/zprofile ]] && source /etc/zsh/zprofile

# Source my modularized dotfiles
for F in ~/.zsh/[0-9][0-9]-*.zsh; do
    [[ -x $F ]] && source $F
done

# Load custom stuff from a local zshrc
[[ -r "$HOME/.$(hostname).zshrc" ]] && source "$HOME/.$(hostname).zshrc"

# this snippet is required in zshrc for TASKS
[[ -n "$TASK" && -x ~/.zsh/tasks/$TASK.zsh ]] \
    && source ~/.zsh/tasks/$TASK.zsh $TASK \
    || true

# vim:set expandtab foldmethod=indent:
