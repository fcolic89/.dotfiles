#stops a one or all docker containers
function dstop(){
  if [ "$1" = "-a" ]; then
    command docker container stop $(command docker ps -q)
  elif [ -n "$1" ]; then
    command docker container stop "$1"
  else
    if [ ! $(command -v "fzf") ]; then
      echo "Error: fzf needs to be installed to use this function.(https://github.com/junegunn/fzf)"
      return 1
    fi
    local options=$(command docker ps | command awk 'NR > 1 {print $1, $2, $NF}')
    local selected_option=$(command echo "${options[@]}" | command fzf --header=$'CONTAINER ID  IMAGE  NAME\n' --layout=reverse --prompt="Select a container: ")
    command docker container stop $(echo $selected_option | command awk '{print $3}')
  fi 
}

#remove one or all docker images
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
    local selected_option=$(command echo "${options[@]}" | command fzf --header=$'REPOSITORY  TAG  IMAGE ID\n' --layout=reverse --prompt="Select an image: ")
    command docker rmi $(echo $selected_option | command awk '{print $3}')
  fi
}

#removes one or all docker container
function drm(){
  if [ "$1" = "-a" ]; then
    docker rm $(docker ps -aq)
  elif [ -n "$1" ]; then
    docker rm "$1"
  else
    if [ ! $(command -v "fzf") ]; then
      echo "Error: fzf needs to be installed to use this function.(https://github.com/junegunn/fzf)"
      return 1
    fi
    local options=$(command docker ps -f "status=exited" | command awk 'NR > 1 {print $1, $2, $NF}')
    local selected_option=$(command echo "${options[@]}" | command fzf --header=$'CONTAINER ID  IMAGE  NAME\n' --layout=reverse --prompt="Select an image: ")
    command docker rm $(echo $selected_option | command awk '{print $3}')
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

#a function for interactive selection of a container that will execute /bin/bash
function dbash(){
  if [ ! $(command -v "fzf") ]; then
    echo "Error: fzf needs to be installed to use this function.(https://github.com/junegunn/fzf)"
    return 1
  fi
  local options=$(command docker ps | command awk 'NR > 1 {print $1, $2, $NF}')
  local selected_option=$(command echo "${options[@]}" | command fzf --header=$'CONTAINER ID  IMAGE  NAME\n' --layout=reverse --prompt="Select a container: ")
  command docker exec -it $(command echo $selected_option | command awk '{print $3}') /bin/bash $@
}
