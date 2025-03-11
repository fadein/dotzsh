# fadein's zshrc
# vim:set expandtab foldmethod=indent:

# Source global definitions
[[ -r /etc/zsh/zprofile ]] && source /etc/zsh/zprofile

# Source my modularized dotfiles
for F in ~/.zsh/[0-9][0-9]-*.zsh(N); do
    [[ -x $F ]] && source $F
done

# Source auxiliary dotfiles symlinked into active
# The (N) avoids the "no matches found" warning
for F in ~/.zsh/active/*.zsh(N); do
    [[ -x $F ]] && source $F
done

# Load custom stuff from a host-specific zshrc (if marked executable)
[[ -x ~/.$HOSTNAME.zshrc ]] && source ~/.$HOSTNAME.zshrc

# this snippet is required in zshrc for TASKS
[[ -n "$TASK" && -x ~/.zsh/tasks/$TASK.zsh ]] \
    && source ~/.zsh/tasks/$TASK.zsh $TASK \
    || true

[[ -n "$_TUTR" ]] && source $_TUTR || true  # shell tutorial shim DO NOT MODIFY

# vim:set expandtab foldmethod=indent:
