__open_in_editor(){
  local option=$(command find . -not -path '*/node_modules*' -not -path '*.git*' | command fzf --reverse)
  if [ -n "$option" ]; then
    local option_path=$(command realpath $option || command readlink -f $option)
    case "$EDITOR" in
      "nvim")
        if [ -f "$option_path" ]; then
          $EDITOR -c "cd $(command dirname $option_path)" $option_path
        else
          $EDITOR -c "cd $option_path" $option_path
        fi
        ;;
      "vim")
        if [ -f "$option_path" ]; then
          echo $option_path | xargs -o $EDITOR -c "cd $(command dirname $option_path)"
        else
          echo $option_path | xargs -o $EDITOR -c "cd $option_path"
        fi
        ;;
      *)
        $EDITOR $option_path
        ;;
    esac
  fi

  return $?
}

# create a zle widget
zle -N __open_in_editor
 
# bind keys to widgets
bindkey -M viins '^u' __open_in_editor
#bindkey -M vicmd '^u' __open_in_editor
bindkey -M viins '^f' vi-cmd-mode 
