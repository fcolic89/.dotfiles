function gcr(){
  local username="$(command git config user.name)"
  if [ -z "$username" ]; then
    >&2 echo "Git username not found!"
    return 1
  fi

  local ssh="git@github.com:$username"
  local http="https://github.com/$username"

  if [ "$1" = "-h" ]; then
    command git clone "$http/$2.git"
  else
    command git clone "$ssh/$1.git"
  fi
}

