if [ $(uname) = "Linux" ]; then
  alias here="xdg-open ."
  alias op="xdg-open"
fi

if [ $(command -v "apt") ]; then
  alias au="sudo apt update"
  alias ulist="apt list --upgradable"
  alias ag="sudo apt upgrade"
  alias ai="sudo apt install"
  alias arm="sudo apt autoremove"
  alias apr="sudo apt purge"
  alias acp="apt-cache policy"
fi

alias mv="mv -i"
alias cp="cp -i"
alias cl="clear"
alias py="python3"
alias e="nvim"
alias ee="subl"
alias af="alias | grep"
alias cdot="cd ~/.dotfiles"
alias lapcon="ssh atlas@192.168.2.1"
alias lapsftp="sftp atlas@192.168.2.1"
