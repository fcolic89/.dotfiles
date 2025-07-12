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

if [ $(command -v "mvn") ]; then
  alias jcp="mvn archetype:generate -DarchetypeArtifactId=maven-archetype-boilerplate -DarchetypeGroupId=com.boilerplate"
fi

alias mv="mv -i"
alias cp="cp -i"
alias cl="clear"
alias py="python3"
alias e="nvim"
alias ee="subl"
alias af="alias | grep"
alias cdot="cd ~/.dotfiles"
