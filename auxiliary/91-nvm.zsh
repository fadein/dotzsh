if [[ -d "$HOME/.config/nvm" ]]; then
    export NVM_DIR="$HOME/.config/nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"  # This loads nvm
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion, should also be Zsh compatible
fi
