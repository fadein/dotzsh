# fadein's zshrc
# vim:set expandtab foldmethod=indent:

# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"

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

[[ -n "$_TUTR" ]] && source $_TUTR || true  # shell tutorial shim DO NOT MODIFY

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"

# vim:set expandtab foldmethod=indent:
