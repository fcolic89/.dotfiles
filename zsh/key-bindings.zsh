# create a zle widget
zle -N __open_in_editor
 
# bind keys to widgets
bindkey '^u' __open_in_editor

# open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# shift-tab for selecting previous completion item 
bindkey '^[[Z' reverse-menu-complete
