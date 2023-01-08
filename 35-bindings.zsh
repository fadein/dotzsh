bindkey -e
bindkey "\C-X\C-E" edit-command-line

#fix "delete emits a ~"
bindkey "^[[3~"   delete-char
bindkey "^[[3;2~" delete-char
bindkey "^[[3$"   delete-char

# Insert command line to quickly eval an empty scheme expression with the chicken interpreter
bindkey -s "\es" "\C-acsi -p '\C-e'\C-b"


# Remove binding to Ctrl-D (default is delete-char-or-list)
# Aesthetic improvement in lectures where stty(1) disables Ctrl-D's EOF meaning
bindkey -r "\C-D"
