#!/usr/bin/env zsh

PURPOSE="Play NetHack locally or online"
VERSION="5.1.1"
   DATE="Fri Jun 26 2026"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r

WIZKIT=$HOME/games/wizkit.txt
FONT="departuremono nerd font"
DPI=${DPI:-$(xrdb -get Xft.dpi)}

# terminal dimensions stored in arrays (columns lines)
typeset -a TARGET_SIZE=(131 36)
typeset -a TERM_SIZE=()
typeset -a PREV_SIZES=() # ( columns0 lines0  columns1 lines1 ... )

# indices into terminal dimension arrays
typeset -ir C=1 L=2

# return codes of term-size-cmp()
typeset -r _MATCH=match _TERM_TOO_SMALL=too-small _TERM_BIGGER=bigger _UNKNOWN=unknown


# Store the previous terminal dimensions in the array PREV_SIZES,
# Then store the current terminal dimensions into TERM_SIZE
get-term-size() {
    TERM_SIZE=($(tput -S <<<$'cols\nlines'))
    PREV_SIZES=($TERM_SIZE $PREV_SIZES)
}


# Return true when there are enough terminal sizes to compare, and the first pair differs from the 2nd pair
term-size-changed() {
    (( $#PREV_SIZES >= 4 )) && (( ($PREV_SIZES[$C] != $PREV_SIZES[$C + 2]) || ($PREV_SIZES[$L] != $PREV_SIZES[$L + 2]) ))
}


# Compare the current terminal size with the target size
# set $REPLY to one of $_UNKNOWN $_MATCH, $_TERM_TOO_SMALL, or $_TERM_BIGGER
term-size-cmp() {
    get-term-size
    if (( $#TERM_SIZE == 0 )); then
        REPLY=$_UNKNOWN
    elif (( $TERM_SIZE[$C] == $TARGET_SIZE[$C] && $TERM_SIZE[$L] == $TARGET_SIZE[$L] )); then
        REPLY=$_MATCH
    elif (( $TERM_SIZE[$C] < $TARGET_SIZE[$C] || $TERM_SIZE[$L] < $TARGET_SIZE[$L] )); then
        REPLY=$_TERM_TOO_SMALL
    else
        REPLY=$_TERM_BIGGER
    fi
}


# Emit terminal escape sequences that set the terminal's font size in pixels
set-font-size() {
    local size=${1:-32}

    if [[ -n $TERMINOLOGY ]]; then
        print -n "\e]50;:size=$size\e\a"

        # set TERM=xterm for Terminology's sake
        # when it enters Vim in 256 color mode, it looks like crap
        TERM=xterm

    elif [[ $TERM == rxvt-unicode* ]]; then
        print -n "\e]710;xft:$FONT:pixelsize=$size:antialias=true\a"

	elif [[ $TERM == alacritty ]]; then
		# calculate equivalent point size for font size given in pixels
		local point_size=$(( $size * 72 / $DPI ))
		alacritty msg config font.size=$point_size
    fi

    print "Setting font size $size..."
	command sleep .05
}


# Perform a binary search for a font size that matches as closely as possible
# the target dimensions without being too small.
#
# This task is complicated by the fact that only the terminal dimensions are
# known, not the prevailing font size.  Thus, the high and low boundaries must
# first be established.
nethack-right-size() {
    # high and low guesses for starting the search
    local max=72 min=18

    clear
    term-size-cmp
    case $REPLY in
        $_MATCH)
            return 0;;
        $_UNKNOWN)
            print -P "%B%F{red}Unable to determine terminal dimensions%f%b"
            return 1
            ;;
    esac

    # find high boundary
    local hi=$max
    local -i i=0
    while (( ++i )); do
        set-font-size $hi
        term-size-cmp
        # idempotency check for subsequent iterations
        if (( i > 2 )) && ! term-size-changed; then
            print -P "%B%F{red}Terminal size is not changing%f%b"
            return 1
        fi
        case $REPLY in
            $_MATCH)
                return 0 ;;
            $_UNKNOWN)
                print -P "%B%F{red}Unable to determine terminal dimensions%f%b"
                return 1 ;;
            $_TERM_TOO_SMALL)
                break ;;
            *)
                (( hi *= 2 )) ;;
        esac
    done

    # find low boundary
    local lo=$min
    while true; do
        set-font-size $lo
        term-size-cmp
        # idempotency check
        if ! term-size-changed; then
            print -P "%B%F{red}Terminal size is not changing%f%b"
            return 1
        fi
        case $REPLY in
            $_MATCH)
                return 0 ;;
            $_UNKNOWN)
                return 1 ;;
            $_TERM_BIGGER)
                break ;;
            *)
                (( lo /= 2 )) ;;
        esac
    done

    local mid=-1 prev=0 good=0
    while true; do
        (( mid = (hi + lo) / 2 ))
        (( mid == prev )) && break  # we've been here before
        set-font-size $mid
        term-size-cmp
        case $REPLY in
            $_MATCH)
                return 0 ;;
            $_UNKNOWN)
                return 1 ;;
            $_TERM_BIGGER)
                (( lo = prev = mid ))
                # keep the largest good value seen so far
                (( mid > good )) && (( good = mid ))
                ;;
            $_TERM_TOO_SMALL)
                (( hi = prev = mid ))
                ;;
        esac
    done

    # if we didn't find a font size that results in an exact match,
    # use the last seen font size that gave a terminal larger than
    # the target
    [[ -n $good && $good != $prev ]] && set-font-size $good

    return 0
}


countdown() {
    zmodload zsh/zselect

	if [[ $# -lt 1 ]]; then
		print 'Usage: countdown SECONDS [CMD ARGS]'
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
	print

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
        [[ -z ${noxkbmap+1} ]] && setxkbmap us,colehack -option grp:ctrls_toggle -option grp_led:scroll
        clear
        ln -sf $TTY /tmp/nethack.tty
        print "After logging in run 'nh.tty' to fix the colors"
        countdown 2
    else
        return 1
    fi
}


spawn() {
    case $TASKNAME in
        nao) ssh nethack@alt.org ;;
        hardfought) ssh nethack@hardfought.org ;;
        nethack) MAILREADER=/usr/bin/mutt command nethack ;;
        wizard)
            if [[ -a $WIZKIT ]]; then
                WIZKIT=$WIZKIT MAILREADER=/usr/bin/mutt command nethack -D
            else
                print "wizkit.txt not found at '$WIZKIT'"
                pause
                MAILREADER=/usr/bin/mutt command nethack -D
            fi ;;
    esac
}


cleanup() {
    [[ -z ${noxkbmap+1} ]] && setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
