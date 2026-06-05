pi() {
    if [[ -d ~/.pi ]]; then
        env -u GEMINI_API_KEY -u OPENAI_API_KEY -u ANTHROPIC_API_KEY -u PERPLEXITY_API_KEY pi
    else
        print -P "%B%F{red}pi does not seem to be installed here%f%b"
        print -P "%B%F{red}Try running %F{green}npm install -g --ignore-scripts @earendil-works/pi-coding-agent%f%b"
    fi
}
