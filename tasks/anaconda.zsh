#!/usr/bin/zsh

PURPOSE="Enable/disable Anaconda Python Distribution"
VERSION="1.0"
   DATE="Fri Dec 29 11:41:57 MST 2017"
 AUTHOR="Erik Falor <erik.falor@usu.edu>"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    if ! [[ -d ~/anaconda3/bin ]]; then
        die 'Anaconda 3 distribution is not installed in $HOME'
    fi
}

env() {
    PATH=~/anaconda3/bin:$PATH
    [[ -n $PATH    ]] && PATH=$(uniquify $PATH)
    echo "You're now using Anaconda python in this shell"
}

cleanup() {
    echo "You're no longer using Anaconda python in this shell"
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
