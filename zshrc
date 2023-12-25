# fadein's zshrc
# vim:set expandtab foldmethod=indent:

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

shortcuts() { # DO NOT MODIFY. SHORTCUTS COMMAND ADDED BY SHELL TUTOR
cat <<-:
[1;36mShortcut[0m | [1;36mAction[0m
---------|----------------------------------------------
  [0;35mUp[0m     | Bring up older commands from history
  [0;35mDown[0m   | Bring up newer commands from history
  [0;35mLeft[0m   | Move cursor BACKWARD one character
  [0;35mRight[0m  | Move cursor FORWARD one character
[0;35mBackspace[0m| Erase the character to the LEFT of the cursor
  [0;35mDelete[0m | Erase the character to the RIGHT the cursor
  [0;35m^A[0m     | Move cursor to START of line
  [0;35m^E[0m     | Move cursor to END of line
  [0;35mM-B[0m    | Move cursor BACKWARD one whole word
  [0;35mM-F[0m    | Move cursor FORWARD one whole word
  [0;35m^C[0m     | Cancel (terminate) the currently running process
  [0;35mTab[0m    | Complete the command or filename at cursor
  [0;35m^W[0m     | Kill (cut) BACKWARD from cursor to beginning of word
  [0;35m^K[0m     | Kill FORWARD from cursor to end of line (kill)
  [0;35m^Y[0m     | Yank (paste) text to the RIGHT the cursor
  [0;35m^L[0m     | Clear the screen while preserving command line
  [0;35m^U[0m     | Kill the entire command line
:
}
