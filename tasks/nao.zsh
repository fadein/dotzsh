#!/bin/env zsh

PURPOSE="Play on nethack.alt.org or hardfought.org"
VERSION="4.0"
   DATE="Fri Sep 26 2025"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
FONT="departuremono nerd font"


# use tput(1) to find the dimensions of the terminal
# save in the global array cols_lines
declare -a cols_lines  # [columns lines]
get-size() {
    cols_lines=($(tput cols lines))
}


terminal-font-size() {
    local size=${1:-32}

    if [[ -n $TERMINOLOGY ]]; then
        echo -n "\e]50;:size=$size\e\a"

        # set TERM=xterm for Terminology's sake
        # when it enters Vim in 256 color mode, it looks like crap
        TERM=xterm

    elif [[ $TERM == rxvt-unicode* ]]; then
        echo -n "\e]710;xft:$FONT:pixelsize=$size:antialias=true\a"

	elif [[ $TERM == alacritty ]]; then
		# calculate equivalent point size for font size given in pixels
		local point_size=$(( $size * 72 / ${DPI:-120} ))
		alacritty msg config font.size=$point_size
    fi

    print "Trying font size $size..."
	sleep .15
}


nethack-right-size() {
    local VERSION="2.0"

    declare -r max=76
    declare -r min=12
    declare -r step=2
    declare -r X=1
    declare -r Y=2
    declare -r DPI=$(xrdb -get Xft.dpi)

    declare -a target_size=(131 36)  # ( columns lines )
    declare -a orig_size             # ( columns lines )
    local orig_font_size=
    local good=

    # get the current size of the screen so I can reset back to the original size
    # if we fail to find a good match
    get-size
    if (( ${cols_lines[$X]} == ${target_size[$X]} && ${cols_lines[$Y]} == ${target_size[$Y]} )); then
        print "${cols_lines[$X]} == ${target_size[$X]} && ${cols_lines[$Y]} == ${target_size[$Y]}"
        print "This font size is just right..."

        return
    fi

    orig_size=(${cols_lines[@]})

    # Starting at the largest font, reduce the size of font by
    # increments of $step until both of the target dimensions are met
    for ((i = max; i >= min; i -= step )); do
        terminal-font-size $i
        get-size
        print "At font size $i dimensions are ${cols_lines[$X]}x${cols_lines[$Y]}"

        if (( ${cols_lines[$X]} == ${orig_size[$X]} && ${cols_lines[$Y]} == ${orig_size[$Y]} )); then
            orig_font_size=$i
            print "The original font size was $i"
        fi

        if (( ${cols_lines[$X]} >= ${target_size[$X]} && ${cols_lines[$Y]} >= ${target_size[$Y]} )); then
            print "${cols_lines[$X]} >= ${target_size[$X]} && ${cols_lines[$Y]} >= ${target_size[$Y]}"
            print "Font size $i is just right..."
            good=1
            break
        fi
    done

    if [[ -z $good && -n $orig_font_size ]]; then
        print "Appropriate font size not found; restoring to original size"
        print "\033]710;xft:hack:pixelsize=${orig_font_size}:antialias=true\007"
        return 1

    elif [[ -z $good && -z $orig_font_size ]]; then
        print "Failed to find a good font size and I don't know what size to reset to. Sorry!"
        return 2

    elif [[ -n $good ]]; then
        return 0

    else
        print "How did we arrive at line $LINENO?"
        return 3

    fi
}


countdown() {
    zmodload zsh/zselect

	if [[ $# -lt 1 ]]; then
		echo 'Usage: countdown SECONDS [CMD ARGS]'
		return 1
	fi
	local N=$1
	shift
	local MSG CEOL=$(tput el 2>&1)

	[[ $? -eq 0 ]] && MSG=$CEOL
	[[ $# -ge 1 ]] && MSG=${MSG}"Running '$@' in "

	until [[ $N -le 0 ]]; do
		printf $'\r%s%d...' "$MSG" $N
		zselect -t 100  # sleep for 100 centiseconds = 1 second
		((N--))
	done
	echo

	[[ $# -ge 1 ]] && eval $@ || true
}


setup() {
    if [[ -d $HOME/.local/bin/ && ! -x $HOME/.local/bin/nh.tty ]]; then
        cat <<SHIM > $HOME/.local/bin/nh.tty
#!/bin/zsh

[[ -L /tmp/nethack.tty ]] && tcd --scheme=NetHack > /tmp/nethack.tty
SHIM
    chmod +x $HOME/.local/bin/nh.tty
    fi

    if nethack-right-size; then
        setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
        clear
        ln -sf $TTY /tmp/nethack.tty
        print "After logging in run 'nh.tty' to fix the colors"
        countdown 2
    else
        return 1
    fi
}


spawn() {
    setopt local_options xtrace
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
