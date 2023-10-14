#!/bin/env zsh

PURPOSE="Play on nethack.alt.org or hardfought.org"
VERSION="2.0"
   DATE="Sat Sep 30 22:36:58 MDT 2023"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
    clear
    print $'Entering the Dungeons of Doom...\033]710;xft:hack:pixelsize=48:antialias=true\007'
    tcd --palette
    tcd --scheme=NetHack
}

spawn() {
    case $TASKNAME in
        nao) ssh nethack@alt.org ;;
        hardfought) ssh nethack@hardfought.org ;;
    esac
}

cleanup() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:


# use tput(1) to find the dimensions of the terminal
# save in the global array LC
get-size() {
    LC=($(tput cols lines))
}

nethack-right-size() {
    VERSION="1.1"

    MAX_SIZE=76
    MIN_SIZE=12
    STEP=2

    declare -a TARGET_SIZE=(130 36)
    declare -a LC  # [columns lines]
    declare -a ORIG_SIZE  # [columns lines]
    ORIG_FONT_SIZE=
    GOOD=

    if ! tcd --scheme | grep -q nethack; then
        tcd --scheme=nethack
        sleep .25
    fi


    # get the current size of the screen so I can reset back to the original size
    # if we fail to find a good match
    get-size
    ORIG_SIZE=(${LC[@]})


    # Starting at the largest font, reduce the size of font by
    # increments of STEP until both of the target dimensions are met
    for ((i = MAX_SIZE; i >= MIN_SIZE; i -= STEP )); do
        print "\033]710;xft:hack:pixelsize=${i}:antialias=true\007"
        # print "[H[2JTrying font size $i..."
        print "Trying font size $i..."
        sleep .05
        get-size
        print "At font size $i dimensions are ${LC[1]}x${LC[2]}"

        if (( ${LC[1]} == ${ORIG_SIZE[1]} && ${LC[2]} == ${ORIG_SIZE[2]} )); then
            ORIG_FONT_SIZE=$i
            print "The original font size was $i"
        fi

        if (( ${LC[1]} >= ${TARGET_SIZE[1]} && ${LC[2]} >= ${TARGET_SIZE[2]} )); then
            print "${LC[1]} >= ${TARGET_SIZE[1]} && ${LC[2]} >= ${TARGET_SIZE[2]}"
            print "Font size $i is just right..."
            GOOD=1
            break
        fi
    done

    if [[ -z $GOOD && -n $ORIG_FONT_SIZE ]]; then
        print "Appropriate font size not found; restoring to original size"
        print "\033]710;xft:hack:pixelsize=${ORIG_FONT_SIZE}:antialias=true\007"

    elif [[ -z $GOOD && -z $ORIG_FONT_SIZE ]]; then
        print "Failed to find a good font size and I don't know what size to reset to. Sorry!"

    elif [[ -n $GOOD ]]; then
        case $(basename $0) in
            nethack) /usr/games/nethack ;;
            hardfought) ssh nethack@hardfought.org ;;
            *) echo "Name of this script is $0; I'm unsure which game to play" ;;
        esac

    else
        print "Never found a good font size"

    fi
}
