#!/usr/bin/env bash

 #set -e

color_yellow='\e[33m'
color_red='\e[31m'
nocolor='\e[0m'
dotfiles="$HOME/.dotfiles"

info_message() {
    echo -e "$color_yellow[EXTEDED SETUP]=> $1$nocolor"
}

info_message "Linking tmux config"
ln -sv "$dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"

info_message "Linking vim config"
ln -sv "$dotfiles/vim/.vimrc" "$HOME/.vimrc"

if [ $(echo "$XDG_CURRENT_DESKTOP" | grep "GNOME") ]; then
  read -p "$(info_message "Setup gnome keybinds [y/N]: ")" awn
  if [[ "$awn" == [Yy]* ]]; then
    . $dotfiles/misc/gnome-keybinds.sh
  fi
fi

if [ $(command -v "git") ]; then
  read -p "$(info_message "Setup git [y/N]: ")" awn
  if [[ "$awn" == [Yy]* ]]; then
    . $dotfiles/git/setup-git.sh
  fi
fi
