alias python='python3'

bluetooth() {
    sudo /etc/rc.d/rc.bluetooth restart
}

colehack() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

clukhacy() {
    setxkbmap colehack,us -option grp:ctrls_toggle -option grp_led:scroll
}

twindisp() {
    xrandr --output eDP-1 --mode 3840x2160 --output VIRTUAL1 --off --output HDMI1 --left-of eDP-1 --auto
}

imhere() {
    figlet -f small I\'m here,$'\n'just speak up | cmatrix -b -C cyan
}

illbeback() {
    figlet -f small I\'ll be back$'\n'in ${1=5} minutes| cmatrix -b -C green
}

flowblade() {
    OLD_DPI=$(xrdb -q | \grep Xft.dpi)
    # for 4k
    echo "Xft.dpi: 232" | xrdb -override

    # for 1080p
    # echo "Xft.dpi: 96" | xrdb -override
    #dbus-run-session -- flatpak run io.github.jliljebl.Flowblade
    # wip: find my custom build of MLT
    PYTHONPATH=/usr/local/lib64/python3.9/site-packages ~/build/flowblade/flowblade-trunk/flowblade
    echo "$OLD_DPI" | xrdb -override
}

function {hibernate,suspend} {
    sudo loginctl $0
}

# vim: set filetype=zsh expandtab:
