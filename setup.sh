#!/usr/bin/env bash

NAME="SETUP.SH"
GITHUB_REPO="https://github.com/fcolic89/.dotfiles"
INSTALL_DIR="$HOME/.dotfiles"

color_yellow='\e[33m'
color_red='\e[31m'
nocolor='\e[0m'

info_message() {
    echo -e "$color_yellow[$NAME]=> $1!$nocolor"
}

error_message() {
    echo -e "$color_red[$NAME]=> $1!$nocolor"
}

backup_files () {
    local backup_dir="$HOME/.old-dotfiles"
    local files=(
      bashrc
      zshrc
      profile
      zprofile
      vimrc
    )

    info_message "Backing up old dotfiles"
    mkdir -p $backup_dir

    for file in ${files[@]}; do
       mv ~/.$file $backup_dir
    done
}

install_programs(){
   if [ "$PROGRAMS" == "1" ]; then
     return 0
   fi

   local programs=(
      htop
      zsh
      tig
      vim
      tmux
      fzf
      ranger
   )

   info_message "Installing programs"
   if [ "$(uname)" == "Linux"  ]; then
     if [ $(command -v "apt") ]; then
       sudo apt update
       sudo apt install -y "${programs[@]}"
     elif [ $(command -v "dnf") ]; then
       sudo dnf check-update
       sudo dnf install "${programs[@]}"
      fi
   else
     error_message "No known way of installing programs"
   fi
}

install_ohmyzsh (){
    if [ -d "$HOME/.oh-my-zsh" ]; then
      info_message "Oh-my-zsh is already inslled, trying to update"
      command git -C "$ZSH" pull
    else
      info_message "Installing oh-my-zsh"
      exit | sh -c "$(command curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null
    fi

    info_message "Installing syntax highlighting plugin"
    command git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2> /dev/null

    info_message "Installing custom theme"
    local custom_theme="attempt"
    command ln -sfv "$INSTALL_DIR/themes/$custom_theme.zsh-theme" "$HOME/.oh-my-zsh/custom/themes" 
}

switch_git_branch(){
  # Switch to a different brach, if one is provided by the user
  if [ -n "$GITHUB_BRANCH" ]; then
    command git -C "$INSTALL_DIR" fetch origin "$GITHUB_BRANCH" 2> /dev/null
    if [ $(command git -C "$INSTALL_DIR" branch -a | command grep "$GITHUB_BRANCH") 2> /dev/null ]; then
      info_message "Switching to branch $GITHUB_BRANCH"
      command git -C "$INSTALL_DIR" switch "$GITHUB_BRANCH"
    fi
  fi
}

get_dotfiles_from_git(){
  if [ -d "$INSTALL_DIR/.git" ]; then
    switch_git_branch
    # Update repo
    info_message "Dotfiles already installed in $INSTALL_DIR, trying to update using git"
    command git -C "$INSTALL_DIR" pull || {
      error_message "Failed to update dotfiles, run 'git pull' in $INSTALL_DIR yourself"
      exit
    }
  else
    # Clone repo
    mkdir -p "$INSTALL_DIR"
    info_message "Cloning git repo"
    command git clone "$GITHUB_REPO" "$INSTALL_DIR" || {
      error_message "Failed to clone dotfiles repo! Better luck next time."
      exit
     }
    switch_git_branch
  fi
}

link_dotfiles () {
    info_message "Linking dotfiles"
    for src in $(command find -H "$INSTALL_DIR" -maxdepth 2 -name '*.slink' -not \( -path '*.git*' \) -not \( -path '*neovim*' \))
    do
      dst="$HOME/.$(basename "${src%.*}")"
      command ln -sfv "$src" "$dst"
    done
}

main(){
  if [ ! $(command -v "git") ] || [ ! $(command -v "curl") ]; then
    error_message "Failed to start setup script. Git and curl need to be installed!"
    exit
  fi
  backup_files
  get_dotfiles_from_git
  install_programs
  install_ohmyzsh
  link_dotfiles
}

main

