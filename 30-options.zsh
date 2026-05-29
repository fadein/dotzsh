# enable esc-p command search, which completes on the beginning of the line
# typed so far
set ESC-P

# +,$sort /^setopt \(no_\)\?/u
setopt append_history  # append each shell's history to the file rather than replacing it
setopt auto_cd  # If a command cannot be run but is the name of a directory, cd into that directory
setopt auto_continue
setopt brace_ccl
setopt no_cdable_vars
setopt extended_glob
setopt extended_history
setopt hist_expire_dups_first  # Remove the oldest duplicate history event before trimming a unique event
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt notify no_beep
setopt pushd_ignore_dups
setopt pushd_to_home
