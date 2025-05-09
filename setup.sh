#!/usr/bin/env bash

name="SETUP.SH"
github_repo="https://github.com/fcolic89/.dotfiles"
install_dir="$HOME/.dotfiles"

color_yellow='\e[33m'
color_red='\e[31m'
nocolor='\e[0m'

info_message() {
  echo -e "$color_yellow[$name]=> $1!$nocolor"
}

error_message() {
  echo -e "$color_red[$name]=> $1!$nocolor"
}

backup_files() {
  local backup_dir="$HOME/.old-dotfiles"
  local files=(
    bashrc
    zshrc
    profile
    zprofile
    vimrc
    tmux.conf
  )

  info_message "Backing up old dotfiles"
  mkdir -p "$backup_dir"

  for file in "${files[@]}"; do
    mv "$HOME/.$file" "$backup_dir"
  done
}

install_programs() {
  local programs=(
    htop
    zsh
    tig
    vim
    tmux
    fzf
    ranger
    ripgrep
    fd-find
  )

  info_message "Installing programs"
  if [ "$(uname)" == "Linux" ]; then
    if [ $(command -v "apt") ]; then
      sudo apt update >/dev/null
      sudo apt install -y "${programs[@]}"
    elif [ $(command -v "dnf") ]; then
      sudo dnf check-update >/dev/null
      sudo dnf install "${programs[@]}"
    fi
  else
    error_message "No known way of installing programs"
  fi
}

install_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info_message "Oh-my-zsh is already inslled, trying to update"
    omz update >/dev/null
  else
    info_message "Installing oh-my-zsh"
    exit | sh -c "$(command curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null
  fi

  info_message "Installing syntax highlighting plugin"
  command git clone "https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null

  info_message "Installing custom theme"
  local custom_theme="attempt"
  command ln -sfv "$install_dir/themes/$custom_theme.zsh-theme" "$HOME/.oh-my-zsh/custom/themes"
}

switch_git_branch() {
  if [ -z "$github_branch" ]; then
    return 0
  fi

  command git -C "$install_dir" fetch origin "$github_branch" 2>/dev/null
  if [ $(command git -C "$install_dir" branch -a | command grep -q "$github_branch") ] 2>/dev/null; then
    info_message "Switching to branch $github_branch"
    command git -C "$install_dir" switch "$github_branch"
  fi
}

get_dotfiles_from_git() {
  if [ -d "$install_dir" ]; then
    error_message "Directory $install_dir already exists."
    exit 1
  fi

  mkdir -p "$install_dir"
  info_message "Cloning git repo"
  command git clone "$github_repo" "$install_dir" || {
    error_message "Failed to clone repo! Better luck next time."
    exit 1
  }
  switch_git_branch
}

link_dotfiles() {
  info_message "Linking dotfiles"
  for src in $(command find -H "$install_dir" -maxdepth 2 -name '*.slink' -not \( -path '*.git*' \)); do
    dst="$HOME/.$(basename "${src%.*}")"
    command ln -sfv "$src" "$dst"
  done
}

install() {
  if [ ! $(command -v "git") ] || [ ! $(command -v "curl") ]; then
    error_message "Failed to start setup script. Git and curl need to be installed!"
    exit
  fi
  backup_files
  get_dotfiles_from_git
  install_programs
  install_ohmyzsh
  link_dotfiles
  source "$install_dir/misc/extended-setup.sh"
}

install
