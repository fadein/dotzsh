function {
    local ZSHDIR=/home/fadein/build/shell-build/zsh
    local d
    for d in $ZSHDIR/zsh-[0-9].*(/); do
        if [[ -x $d/Src/zsh ]]; then
            local z=${d##*/}
            alias $z="SHELL=$d/Src/zsh $d/Src/zsh"
        fi
    done

    zshs() {
        noglob alias +m zsh-[0-9].*
    }
}
