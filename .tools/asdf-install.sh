#!/usr/bin/env bash
set -o pipefail

T_BOLD=$(tput bold)
C_RED=$(tput setaf 1)
C_B_RED="${T_BOLD}$(tput setaf 1)"
C_BLUE=$(tput setaf 4)
C_B_BLUE="${T_BOLD}$(tput bold)$(tput setaf 4)"
C_RESET=$(tput sgr0)

die() {
  printf "\n${C_B_RED}Error:${C_RESET} $@" >&2
  exit 1
}

check_var() {
  [ "${1}" == "" ] && echo "Nothing to do..." && exit
}


plugin=$(asdf plugin list-all | fzf --header="------- [ ASDF - PLUGINS ] --------")
check_var $plugin
plugin=$(echo $plugin | awk '{ print $1 }')

sleep 1
echo "Adding plugin..."
sleep 1

asdf plugin add $plugin
version=$(asdf list-all $plugin | sort -r | fzf --header="--------- [ $plugin - VERSIONS ] --------")
check_var $version

asdf install $plugin $version
asdf global $plugin $version
