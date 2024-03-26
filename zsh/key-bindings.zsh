__open_in_editor(){
  local option=$(command find . -not -path '*/node_modules*' -not -path '*.git*' | command fzf --reverse)
  if [ -n "$option" ]; then
    local option_path=$(command realpath $option || command readlink -f $option)
    if [ "$EDITOR" = "nvim" ]; then
      $EDITOR -c "cd $(command dirname $option_path)" $option_path
    else
      $EDITOR $option_path
    fi
  fi

  return $?
}

# create a zle widget
zle -N __open_in_editor
 
# bind keys to widgets
bindkey -M emacs '^u' __open_in_editor
