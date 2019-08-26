#!/bin/env zsh

 PURPOSE="RoguelikeDev Does The Complete Roguelike Tutorial 2019"
 VERSION="1.1"
    DATE="Mon Jun 17 23:20:58 MDT 2019"
  AUTHOR="fadein"
PROGNAME=$0
TASKNAME=$0:t:r


env() {
    TUTDIR=~/devel/RoguelikeTutorial2019/
    tut() { cd $TUTDIR; }
    tcod() { cd $TUTDIR; }

    tut
    gitprompt
    source bin/activate
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
