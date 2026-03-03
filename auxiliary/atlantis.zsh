# vim: set filetype=zsh expandtab:

python_crash_course=474722

alias python='python3'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT1'

twindisp() {
    xrandr --output eDP-1 --mode 3840x2160 --output VIRTUAL1 --off --output HDMI1 --left-of eDP-1 --auto
}

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
