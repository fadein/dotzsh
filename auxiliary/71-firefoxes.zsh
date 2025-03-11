typeset -a FIREFOXEN
local FF
for FF in /usr/local/stow/firefox-*(/N); do
    eval "${${FF%%.*}:t}() { $FF/bin/firefox; }"
    FIREFOXEN+=(${${FF%%.*}:t})
done

firefoxen() {
    print These Firefoxen are available:
    local FF
    for FF in $FIREFOXEN; do
        print "  $FF"
    done
}

firefoxes() { firefoxen; }
