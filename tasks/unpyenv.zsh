#!/bin/env zsh

 PURPOSE="Remove Pyenv from the environment"
 VERSION="1.0"
    DATE="Tue Jan 20 2026"
  AUTHOR="fadein"
PROGNAME=$0
TASKNAME=$0:t:r

env() {
	setopt local_options ERR_EXIT

	if [[ -n $PYENV_ROOT ]]; then 
		path=(${path:#$PYENV_ROOT*})
		unset PYENV_ROOT
		unset PYENV_SHELL
	fi

	if functions pyenv &>/dev/null; then
		unfunction pyenv
	fi

	print "Pyenv excised from the environment"
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 shiftwidth=4 noexpandtab:
