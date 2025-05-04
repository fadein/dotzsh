# Set a random color scheme unless you're SSH-ing in or spawning a subshell
[[ -z $SSH_CLIENT && $SHLVL -le 3 && $TERM != linux ]] && tcd --random-scheme --palette
