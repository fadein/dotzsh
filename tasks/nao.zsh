#!/bin/env zsh

PURPOSE="Play on nethack.alt.org or hardfought.org"
VERSION="3.1"
   DATE="Tue Oct 17 09:47:33 MDT 2023"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r


declare -a cols_lines  # [columns lines]

# use tput(1) to find the dimensions of the terminal
# save in the global array cols_lines
get-size() {
    cols_lines=($(tput cols lines))
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

    declare -r max=76
    declare -r min=12
    declare -r step=2

    declare -a target_size=(131 36)  # ( columns lines )
    declare -a orig_size             # ( columns lines )
    local orig_font_size=
    local good=

    # get the current size of the screen so I can reset back to the original size
    # if we fail to find a good match
    get-size
    if (( ${cols_lines[1]} == ${target_size[1]} && ${cols_lines[2]} == ${target_size[2]} )); then
        print "${cols_lines[1]} == ${target_size[1]} && ${cols_lines[2]} == ${target_size[2]}"
        print "This font size is just right..."

        return
    fi

    orig_size=(${cols_lines[@]})

    # Starting at the largest font, reduce the size of font by
    # increments of $step until both of the target dimensions are met
    for ((i = max; i >= min; i -= step )); do
        print "\033]710;xft:hack:pixelsize=${i}:antialias=true\007"
        # print "[H[2JTrying font size $i..."
        print "Trying font size $i..."
        sleep .15
        get-size
        print "At font size $i dimensions are ${cols_lines[1]}x${cols_lines[2]}"

        if (( ${cols_lines[1]} == ${orig_size[1]} && ${cols_lines[2]} == ${orig_size[2]} )); then
            orig_font_size=$i
            print "The original font size was $i"
        fi

        if (( ${cols_lines[1]} >= ${target_size[1]} && ${cols_lines[2]} >= ${target_size[2]} )); then
            print "${cols_lines[1]} >= ${target_size[1]} && ${cols_lines[2]} >= ${target_size[2]}"
            print "Font size $i is just right..."
            good=1
            break
        fi
    done

    if [[ -z $good && -n $orig_font_size ]]; then
        print "Appropriate font size not found; restoring to original size"
        print "\033]710;xft:hack:pixelsize=${orig_font_size}:antialias=true\007"

    elif [[ -z $good && -z $orig_font_size ]]; then
        print "Failed to find a good font size and I don't know what size to reset to. Sorry!"

    elif [[ -n $good ]]; then
        return 0

    else
        print "Failed to find a good font size"
        return 1

    fi
}


setup() {
    if nethack-right-size; then
        setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
        clear
        print Entering the Dungeons of Doom on ${TTY:t2} in
        countdown 5
    else
        return 1
    fi
}

spawn() {
    case $TASKNAME in
        nao) ssh nethack@alt.org ;;
        hardfought) ssh nethack@hardfought.org ;;
        nethack) MAILREADER=/usr/bin/mutt command nethack ;;
    esac
}

cleanup() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
