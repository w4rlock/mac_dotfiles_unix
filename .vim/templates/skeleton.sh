#!/usr/bin/env bash

# strict mode
set -o pipefail
set -o nounset
set -o errexit

# colors utils
BOLD=$(tput bold)
C_RESET=$(tput sgr0)


red() {   printf "${BOLD}$(tput setaf 1)${1}${C_RESET}" ; }
blue() {  printf "${BOLD}$(tput setaf 4)${1}${C_RESET}" ; }
green() { printf "${BOLD}$(tput setaf 2)${1}${C_RESET}" ; }
log_info() { echo "$(blue '[')${BOLD}*$(blue ']') - ${@}" ; }



# Show msg and exit program
die() {
  echo "$(red 'Error:') ${@}" >&2
  exit 1
}



# Util to check if your script has dependencies example:
# check_required_programs wget rg fd fzf curl
check_required_programs() {
  for dep in ${@}; do
    which $dep &> /dev/null || die "program '${dep}' is required."
  done
}



usage() {
  cat <<EOF

$(green 'Script Utility for ...')

$(blue 'Usage:')
    $(green $0) [options] [args]

$(blue 'Options:')
    -e | --example        (required)      Description here
    -h | --help                           This help screen"
EOF
  exit 0
}


parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -e|--example)
      EXAMPLE_VALUE="$2"
      shift # past value
      ;;
      --default)
      DEFAULT=YES
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



