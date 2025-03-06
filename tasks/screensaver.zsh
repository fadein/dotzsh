#!/bin/zsh

 PURPOSE="Temporarily disable display powersave mode"
 VERSION=1.5.1
    DATE="Thu Mar  6 2025"
  AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0:t
TASKNAME=$0:t:r

setup() {
    print $'\x1b[0m'
    xset -dpms s off
    xset s off
    CLEANUP_TRAPS=(HUP)
    xset q | command grep "DPMS is"
    cat <<':'
____ ____ ____ ____ ____ _  _ ____ ____ _  _ ____ ____
[__  |    |__/ |___ |___ |\ | [__  |__| |  | |___ |__/
___] |___ |  \ |___ |___ | \| ___] |  |  \/  |___ |  \
         ___  _ ____ ____ ___  _    ____ ___
         |  \ | [__  |__| |__] |    |___ |  \
         |__/ | ___] |  | |__] |___ |___ |__/
:
}

cleanup() {
    print $'\x1b[0m\a'
    xset +dpms
    xset s on
    xset q | command grep "DPMS is"
    cat <<':'
  ___ ___________ ___ ___  ___ ___ __  _____ ____
 (_-</ __/ __/ -_) -_) _ \(_-</ _ `/ |/ / -_) __/
/___/\__/_/  \__/\__/_//_/___/\_,_/|___/\__/_/

                               __   __       __
    _______ _______ ___  ___ _/ /  / /__ ___/ /
   / __/ -_)___/ -_) _ \/ _ `/ _ \/ / -_) _  /
  /_/  \__/    \__/_//_/\_,_/_.__/_/\__/\_,_/
:
}


source $0:h/__TASKS.zsh
