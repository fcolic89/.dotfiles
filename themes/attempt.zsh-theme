export PROMPT_SHOW_USER_INFO=0
export PROMPT_DIRECTORY_DEPTH="2" # empty string for full path

local username() {
   if [[ $PROMPT_SHOW_USER_INFO == 1 ]];then
      echo "[%B%{$FG[012]%}%n%f@%{$FG[012]%}$HOST%f%b]-"
   fi
}

local directory() {
   echo "%{$fg[green]%}%$PROMPT_DIRECTORY_DEPTH~%{$reset_color%}"
}

local current_time() {
   echo "%T"
}

local return_status() {
   echo " %(?..%{$fg[red]%}✘%f|)"
}

# If the current directory is a git repo, show git information
local git_info(){
   if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]]; then
     echo "-[%B$(git_repo_name)%b:%B$(git_super_status)$b]"
   fi
}

# set the git_prompt_info text
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}%{?%G%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[blue]%}%{-%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg_bold[green]%}%{+%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_SEPARATOR=""

# set vi_mode_prompt_info options
INSERT_MODE_INDICATOR="%(?.%B%{$fg[green]%}\u276f%{$reset_color%}%b.%B%{$fg[red]%}\u276f%{$reset_color%}%b"
MODE_INDICATOR="%F{yellow}\u276e%f"
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

# putting it all together
PROMPT='$(username)[%B$(directory)%b]$(git_info)
$(vi_mode_prompt_info)'
RPROMPT='$(return_status)[$(current_time)]'
