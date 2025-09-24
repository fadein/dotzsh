if [[ -d /usr/share/cursor/bin/ ]]; then
    PATH="/usr/share/cursor/bin${PATH:+:${PATH}}"
else
    1>&2 print 'Warning: /usr/share/cursor/bin/ is not a directory, cannot add to PATH'
fi
