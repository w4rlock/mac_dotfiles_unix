#!/usr/bin/env bash
# force strict mode
set -o pipefail
set -o nounset
set -o errexit


# colors utils
BOLD=$(tput bold)
C_RESET=$(tput sgr0)


# util functions to print messages with colors
red() {      printf "${BOLD}$(tput setaf 1)${1}${C_RESET}" ; }
blue() {     printf "${BOLD}$(tput setaf 4)${1}${C_RESET}" ; }
green() {    printf "${BOLD}$(tput setaf 2)${1}${C_RESET}" ; }
log_info() { printf "${LOG_PREFFIX} ${@}\n" ; }
LOG_PREFFIX="$(blue '[')${BOLD}*$(blue ']') -"


# show msg and exit program
die() {
  echo "$(red 'Error:') ${@}" >&2
  exit 1
}


# confirm question and continue
confirm() {
  printf "\n${LOG_PREFFIX} ${@} [y/n]: "
  read ans;
  if [[ "${ans}" != "y" ]]; then exit 1; fi
}


# util to check if your script has dependencies example:
# check_required_programs wget rg fd fzf curl
check_required_programs() {
  for dep in ${@}; do
    which $dep &> /dev/null || die "program '${dep}' is required."
  done
}


# print usage program
usage() {
  local sh_name=$(basename $0)

  cat <<EOF
$(blue 'NAME')
    $sh_name

$(blue 'DESCRIPTION')
    Script Utility for ...

$(blue 'SYNOPSIS')
    $sh_name [options] [args]

$(blue 'OPTIONS')
    -e | --example        (required)      Description here
    -h | --help                           This help screen"
EOF
  exit 0
}


# parse script arguments
# exit when unknown option is setted
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -e|--example)
        EXAMPLE_VALUE="${2}"
        shift # past value
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo $(red "ERR: unknown option ${1}") >&2
        usage
        ;;
    esac
    shift  # past key
  done
}


parse_arguments $@




