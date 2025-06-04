if [[ -d /opt/ollama/bin ]]; then
    PATH="/opt/ollama/bin${PATH:+:${PATH}}"
else
    1>&2 print /opt/ollama/bin is not a directory
fi
