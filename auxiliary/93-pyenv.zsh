# pyenv setup
if [[ -d ~/.pyenv/bin ]]; then
    export PYENV_ROOT=~/.pyenv  # where Pyenv's files live
    [[ -d $PYENV_ROOT/bin ]] && path=( $PYENV_ROOT/bin $path )  # add Pyenv to path
    eval "$(pyenv init - zsh)"  # add Pyenv functions to shell
else
    1>&2 print "Pyenv home not found under ~/.pyenv"
fi
