if [[ -d /opt/ollama/bin ]]; then
    PATH="/opt/ollama/bin${PATH:+:${PATH}}"
else
    1>&2 print 'Warning: /opt/ollama/bin/ is not a directory, cannot add to PATH'
fi
