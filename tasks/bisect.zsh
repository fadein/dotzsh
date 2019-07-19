#!/bin/env zsh

PURPOSE="Git Bisect Demo with Vim"
VERSION="1.1"
   DATE="Fri Apr 12 00:51:23 MDT 2019"
 AUTHOR="fadein"
PROGNAME=$0
TASKNAME=$0:t:r


setup() {
    firefox --new-window 'https://github.com/vim/vim/issues/2151#issuecomment-331970759'

    if [[ -n $TERMINOLOGY ]]; then
        # Set Terminology font to 32 pts
        echo -n "\e]50;:size=32\e\a"

        # set TERM=xterm for Terminology's sake
        # when it enters Vim in 256 color mode, it looks like crap
        TERM=xterm

        sleep .1
    fi
}

env() {
    rebuild() {
        ./configure
        make -j$(nproc) && src/vim -Nu NONE -i NONE -c'so runtime/indent/sh.vim'
    }
    help() {
		cat <<-HELP
		* rebuild() will rebuild and launch vim

		* v8.0.0691 is when the bug is fixed

		* v8.0.1127 is when the bug was noticed

		* ding git bisect run ./indent_bug_test.sh

		* git checkout bisect/bad will take me to the broken commit
		HELP
    }
    cd /tmp/vim.git/
}

cleanup() {
    # restore Terminology font to regular 14 pts
    [[ -n $TERMINOLOGY ]] && echo -n "\e]50;:size=14\e\a"

    cd /tmp/vim.git/
    git bisect reset
    git checkout master
    ./configure
    make -j$(nproc)
}


source $0:h/__TASKS.zsh
# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
