#!/usr/bin/env bash

# strict mode
set -o pipefail
set -o nounset
set -o errexit

# colors
T_BOLD=$(tput bold)
C_B_RED="${T_BOLD}$(tput setaf 1)"
C_B_BLUE="${T_BOLD}$(tput bold)$(tput setaf 4)"
C_RESET=$(tput sgr0)

die() {
  echo "${C_B_RED}Error:${C_RESET} ${@}" >&2
  exit 1
}


check_required_programs() {
  for dep in ${@}; do
    which $dep &> /dev/null || die "program '${dep}' is required."
  done
}


log_info() {
  echo "${C_B_BLUE}[${C_RESET} ${T_BOLD}*${C_RESET} ${C_B_BLUE}]${C_RESET} - ${@}"
}


usage() {
  cat <<EOF

${C_B_BLUE}Usage:${C_RESET} $0 [options] [args]

${C_B_BLUE}Options:${C_RESET}
  -h          This help screen"

EOF
  exit 0
}

#check_required_programs wget curl

