__open_in_editor(){
  if [ -z "$EDITOR" ]; then
   zle -M "Error: cannot open file, no default editor set!" && return 1
  fi

  local option=$(command fdfind --exclude node_modules | command fzf --reverse)
  if [ -n "$option" ]; then
    local option_path="$(pwd)/$option"
    case "$EDITOR" in
      nvim)
        if [ -f "$option_path" ]; then
          $EDITOR -c "cd $(command dirname $option_path)" $option_path
        else
          $EDITOR -c "cd $option_path" $option_path
        fi
        ;;
      vim)
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
