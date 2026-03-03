function {
    local BASHDIR=/home/fadein/build/shell-build/bash
    local d
    for d in $BASHDIR/bash-[0-9].*(/); do
        if [[ -x $d/bash ]]; then
            local b=${d##*/}
            alias $b="SHELL=$d/bash $d/bash"
        fi
    done

    bashes() {
        noglob alias +m bash-[0-9].*
    }
}
