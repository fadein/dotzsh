# vim: set filetype=zsh expandtab:

python_crash_course=474722

alias python='python3'

disenable() {
    (
    cd $HOME/devel/homedir/dotzsh/
    ./linkToHome.sh -r
    )
}

reenable() {
    (
    cd $HOME/devel/homedir/dotzsh/
    ./linkToHome.sh
    )
}

ZSHDIR=/home/fadein/build/shell-build/zsh
alias zsh-5.2='SHELL=$ZSHDIR/zsh-5.2/Src/zsh $ZSHDIR/zsh-5.2/Src/zsh'
alias zsh-5.3.1='SHELL=$ZSHDIR/zsh-5.3.1/Src/zsh $ZSHDIR/zsh-5.3.1/Src/zsh'
alias zsh-5.4.2='SHELL=$ZSHDIR/zsh-5.4.2/Src/zsh $ZSHDIR/zsh-5.4.2/Src/zsh'
alias zsh-5.5.1='SHELL=$ZSHDIR/zsh-5.5.1/Src/zsh $ZSHDIR/zsh-5.5.1/Src/zsh'
alias zsh-5.6.2='SHELL=$ZSHDIR/zsh-5.6.2/Src/zsh $ZSHDIR/zsh-5.6.2/Src/zsh'
alias zsh-5.7='SHELL=$ZSHDIR/zsh-5.7/Src/zsh $ZSHDIR/zsh-5.7/Src/zsh'
alias zsh-5.8='SHELL=$ZSHDIR/zsh-5.8/Src/zsh $ZSHDIR/zsh-5.8/Src/zsh'
alias zsh-5.9='SHELL=$ZSHDIR/zsh-5.9/Src/zsh $ZSHDIR/zsh-5.9/Src/zsh'

zshs() {
    echo zsh-5.2
    echo zsh-5.3.1
    echo zsh-5.4.2
    echo zsh-5.5.1
    echo zsh-5.6.2
    echo zsh-5.7
    echo zsh-5.8
    echo zsh-5.9
}

BASHDIR=/home/fadein/build/shell-build/bash
alias bash-3.2='SHELL=$BASHDIR/bash-3.2/bash $BASHDIR/bash-3.2/bash'
alias bash-4.0='SHELL=$BASHDIR/bash-4.0/bash $BASHDIR/bash-4.0/bash'
alias bash-4.3='SHELL=$BASHDIR/bash-4.3/bash $BASHDIR/bash-4.3/bash'
alias bash-4.4.18='SHELL=$BASHDIR/bash-4.4.18/bash $BASHDIR/bash-4.4.18/bash'
alias bash-4.4='SHELL=$BASHDIR/bash-4.4/bash $BASHDIR/bash-4.4/bash'
alias bash-5.0='SHELL=$BASHDIR/bash-5.0/bash $BASHDIR/bash-5.0/bash'
alias bash-5.1.16='SHELL=$BASHDIR/bash-5.1.16/bash $BASHDIR/bash-5.1.16/bash'
alias bash-5.1.8='SHELL=$BASHDIR/bash-5.1.8/bash $BASHDIR/bash-5.1.8/bash'
alias bash-5.1='SHELL=$BASHDIR/bash-5.1/bash $BASHDIR/bash-5.1/bash'

bashes() {
    echo bash-3.2
    echo bash-4.0
    echo bash-4.3
    echo bash-4.4.18
    echo bash-4.4
    echo bash-5.0
    echo bash-5.1.16
    echo bash-5.1.8
    echo bash-5.1
}
