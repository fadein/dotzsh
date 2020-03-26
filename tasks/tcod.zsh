#!/bin/env zsh

 PURPOSE="RoguelikeDev Does The Complete Roguelike Tutorial 2020"
 VERSION="1.2"
    DATE="Mon Mar 23 21:44:00 MDT 2020"
  AUTHOR="fadein"
PROGNAME=$0
TASKNAME=$0:t:r


env() {
    TUTDIR=~/devel/python/RoguelikeTutorial2019/
    tut() { cd $TUTDIR; }
    tcod() { cd $TUTDIR; }

    tut
    gitprompt
    source bin/activate
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
