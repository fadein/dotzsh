setopt extended_glob brace_ccl

# From /private/etc/zshrc_Apple_Terminal
#
# Resume Support: Save/Restore Shell State
# ...
# The save/restore mechanism as a whole can be disabled by setting an
# environment variable (typically in `${ZDOTDIR:-$HOME}/.zshenv`):
[[ $OSTYPE == darwin* && $TERM_PROGRAM == Apple_Terminal ]] && SHELL_SESSIONS_DISABLE=1
