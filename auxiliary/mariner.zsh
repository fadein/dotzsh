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
