#!/usr/bin/env bash

function start_agent() {
  local keys=( 
    "github-key"
  )

  eval "$(ssh-agent -s)" > /dev/null
  ssh-add

  for key in "${keys[@]}"; do
    local key_path="$HOME/.ssh/$key"

    if [ -f "$key_path" ]; then 
      ssh-add "$key_path" 2> /dev/null
    fi
  done
}

start_agent
