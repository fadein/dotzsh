#!/bin/env zsh

PURPOSE="Play on nethack.alt.org or hardfought.org"
VERSION="3.0"
   DATE="Sun Oct 15 20:52:27 MDT 2023"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r


declare -a LC  # [columns lines]

# use tput(1) to find the dimensions of the terminal
# save in the global array LC
get-size() {
    LC=($(tput cols lines))
}

countdown() {
    if [[ $# -lt 1 ]]; then
        echo 'Usage: countdown SECONDS [CMD ARGS]'
        return 1
    fi

    local N I
    N=$1
    I=1
    shift
    [[ $# -ge 1 ]] && echo "Running '$@' in "

    until [[ $N -eq 0 ]]; do
        if [[ $((I % 10)) -eq 0 ]]; then
            echo "$N... "
        else
            echo -n "$N... "
        fi

        sleep 1
        ((N--, I++))
    done
    echo Done

    if [[ $# -ge 1 ]]; then
        eval $@
    fi
}

nethack-right-size() {
    VERSION="1.1"

    MAX_SIZE=76
    MIN_SIZE=12
    STEP=2

    declare -a TARGET_SIZE=(130 36)
    declare -a ORIG_SIZE  # [columns lines]
    local ORIG_FONT_SIZE=
    local GOOD=

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
        sleep .15
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
        return 0

    else
        print "Never found a good font size"
        return 1

    fi
}


setup() {
    if nethack-right-size; then
        setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
        clear
        countdown 3 print Entering the Dungeons of Doom from ${TTY:t2}...
    else
        return 1
    fi
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
