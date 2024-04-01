#!/bin/zsh

#Program: screensaver.zsh
PURPOSE="Temporarily disable display powersave mode"
VERSION=1.4
   DATE="Mon Mar 18 2024"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

setup() {
    xset -dpms s off
    xset s off
    CLEANUP_TRAPS=(HUP)
    xset q | command grep "DPMS is"
    cat <<':'
   ___ ___________ ___ ___  ___ ___ __  _____ ____
  (_-</ __/ __/ -_) -_) _ \(_-</ _ `/ |/ / -_) __/
 /___/\__/_/  \__/\__/_//_/___/\_,_/|___/\__/_/   
                                                  
              ___          __   __       __
          ___/ (_)__ ___ _/ /  / /__ ___/ /
         / _  / (_-</ _ `/ _ \/ / -_) _  / 
         \_,_/_/___/\_,_/_.__/_/\__/\_,_/  
:
}

cleanup() {
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
