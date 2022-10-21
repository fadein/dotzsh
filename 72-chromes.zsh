typeset -a CHROMIUMS
local CH
for CH in /usr/local/stow/chromium-*(/); do
    eval "${${CH%%.*}:t}() { $CH/bin/chrome; }"
    CHROMIUMS+=(${${CH%%.*}:t})
done

chromiums () {
	print These Chromiums are available:
    local CH
	for CH in $CHROMIUMS
	do
		print "  $CH"
	done
}
