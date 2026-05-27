# Homebrew environment
if [[ -x /opt/homebrew/bin/brew ]]; then
    if [[ $PATH != */opt/homebrew/* ]]; then
        PATH=$PATH:/opt/homebrew/bin:/opt/homebrew/sbin
    fi
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi
