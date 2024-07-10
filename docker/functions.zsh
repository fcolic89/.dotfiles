#a menu for selecting container ids using fzf
function _fzf_container_menu(){
  if [ ! $(command -v "fzf") ]; then
    printf "Error: fzf needs to be installed to use this function.(https://github.com/junegunn/fzf)\n" >&2
    return 1
  fi
  local options
  if [ "$1" = "exited" ]; then
    options=$(command docker ps -f "status=exited" | command awk 'NR > 1 {print $1, $2, $NF}')
  else
    options=$(command docker ps | command awk 'NR > 1 {print $1, $2, $NF}')
  fi
  local selected_ids=$(command echo "${options[@]}" | command fzf --multi --header=$'CONTAINER ID  IMAGE  NAME\n' --layout=reverse --prompt="Select a container: " | command awk '{print $3}')
  echo $selected_ids
}

#stops containers
function dstop(){
  if [ "$1" = "-a" ]; then
    command docker container stop $(command docker ps -q)
  elif [ -n "$1" ]; then
    command docker container stop "$1"
  else
    selected_ids=$(_fzf_container_menu)
    [ $? -ne 0 ] && return 1

    echo $selected_ids | xargs docker container stop 
  fi 
}

#removes containers
function drm(){
  if [ "$1" = "-a" ]; then
    docker rm $(docker ps -aq)
  elif [ -n "$1" ]; then
    docker rm "$1"
  else
    selected_ids=$(_fzf_container_menu "exited")
    [ $? -ne 0 ] && return 1

    echo $selected_ids | xargs docker container rm
  fi
}

#stop and remove containers
function dsnr(){
  selected_ids=$(_fzf_container_menu)
  [ $? -ne 0 ] && return 1

  echo $selected_ids | xargs docker container stop | xargs docker container rm
}

#select a container to execute /bin/bash
function dbash(){
  selected_id=$(_fzf_container_menu)
  [ $? -ne 0 ] && return 1

  command docker exec -it $selected_id /bin/bash $@
}

#remove docker images
function drmi(){
  if [ "$1" = "-a" ]; then
    docker rmi $(docker images -q)
  elif [ -n "$1" ]; then
    docker rmi "$1"
  else
    if [ ! $(command -v "fzf") ]; then
      echo "Error: fzf needs to be installed to use this function.(https://github.com/junegunn/fzf)"
      return 1
    fi
    local options=$(command docker images | command awk 'NR > 1 {print $1, $2, $3}')
    local selected_option=$(command echo "${options[@]}" | command fzf --multi --header=$'REPOSITORY  TAG  IMAGE ID\n' --layout=reverse --prompt="Select an image: ")
    echo $selected_option | command awk '{print $3}' | xargs docker rmi
  fi
}

function dcu(){
  if [ -z "$1" ]; then
    docker compose up 
  elif [ "$1" = "-p" ] && [ -n "$2" ]; then
   docker compose --profile $2 up ${@:3}
  elif [ -n "$1" ] && [ "$1" != "-p" ]; then
   docker compose up $@
  else
    echo "An error occurred while trying to call docker compose up!"
  fi
}
