#!/bin/zsh

PURPOSE="Enable/disable Anaconda Python3 Distribution"
VERSION="1.1"
   DATE="Wed Feb 20 09:20:21 MST 2019"
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

    # Anaconda's Python doesn't recognize TERM=rxvt-unicode
    case $TERM in
    rxvt-unicode*)
        TERM=xterm;;
    esac

    echo "You're now using Anaconda python in this shell"
}

cleanup() {
    echo "You're no longer using Anaconda python in this shell"
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
