#!/usr/bin/env bash

name="SETUP.SH"
git_repo="https://github.com/fcolic89/.dotfiles"
install_dir="$HOME/.dotfiles"

color_yellow='\e[33m'
color_red='\e[31m'
nocolor='\e[0m'

usage() {
  cat <<EOF
config.sh [OPTIONS]

Options:
  --packages, -p     -> install additional packages
  --branch, -b       -> set the name of a branch from which to run the setup script
  --install, -i      -> set a custom install directory
  --help, -h         -> print script options
EOF
}

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

install_packages() {
  [[ -z "$packages" ]] && return 0

  local packages_array=(
    htop
    zsh
    tig
    vim
    tmux
    fzf
    ranger
    ripgrep
    fd-find
    zsh-syntax-highlighting
  )

  info_message "Installing packages"
  if [[ "$(uname)" == "Linux" ]]; then
    if [[ $(command -v "apt") ]]; then
      sudo apt update >/dev/null
      sudo apt install -y "${packages_array[@]}"
    elif [[ $(command -v "dnf") ]]; then
      sudo dnf check-update >/dev/null
      sudo dnf install "${packages_array[@]}"
    fi
  else
    error_message "No known way of installing packages"
  fi
}

switch_git_branch() {
  [[ -z "$git_branch" ]] && return 0

  command git -C "$install_dir" fetch origin "$git_branch" 2>/dev/null
  if [[ $(command git -C "$install_dir" branch -a | command grep -q "$git_branch") ]] 2>/dev/null; then
    info_message "Switching to branch $git_branch"
    command git -C "$install_dir" switch "$git_branch"
  fi
}

get_dotfiles() {
  if [[ -d "$install_dir" ]]; then
    info_message "Directory $install_dir already exists."
    command git -C "$install_dir" rev-parse --is-inside-work-tree 2>/dev/null || {
      error_message "$install_dir is not a git repo"
      exit 1
    }
  else
    mkdir -p "$install_dir"
    info_message "Cloning git repo"
    command git clone "$git_repo" "$install_dir" || {
      error_message "Failed to clone repo! Better luck next time."
      exit 1
    }
  fi

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
  backup_files
  get_dotfiles
  install_packages
  link_dotfiles
}

if [[ ! $(command -v "git") ]] || [[ ! $(command -v "curl") ]]; then
  error_message "Failed to start setup script. Git and curl need to be installed!"
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
  -p | --packages)
    packages=1
    shift
    ;;
  -b | --branch)
    git_branch="$2"
    shift 2
    ;;
  -i | --install)
    install_dir="$2"
    shift 2
    ;;
  -h | --help)
    usage
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    error_message "Entered an invalid option: $1"
    usage
    exit 1
    ;;
  esac
done

install
