#!/usr/bin/env bash

if [ ! $(command -v "git") ]; then
  echo "Git is required to run this script!"
  return 1 2> /dev/null || exit 1
fi

printf "Enter git username: "
read username
printf "Enter git email: "
read email

command git config --global user.name $username
command git config --global user.email $email

if [ $(command -v "nvim") ]; then
  command git config --global core.editor nvim
elif [ $(command -v "vim") ]; then
  command git config --global core.editor vim
fi

command git config --global init.defaultBranch main
command git config --global column.ui auto
command git config --global branch.sort -comitterdate

mkdir -p $HOME/.ssh
ssh-keygen -t ed25519 -C "$email" -f $HOME/.ssh/github-key

eval "$(ssh-agent -s)" > /dev/null
ssh-add $HOME/.ssh/github-key
