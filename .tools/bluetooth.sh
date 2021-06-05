#!/usr/bin/env bash
# Script Features: toggle mute, set-volumen, connect, disconnect
# pactl
# pacmd
# bluetoothctl
# fzf

set -o pipefail

T_BOLD=$(tput bold)
C_RED=$(tput setaf 1)
C_B_RED="${T_BOLD}$(tput setaf 1)"
C_BLUE=$(tput setaf 4)
C_B_BLUE="${T_BOLD}$(tput bold)$(tput setaf 4)"
C_RESET=$(tput sgr0)

readonly action=$1

get_device_id() {
  pacmd list-sinks \
    | grep -Po 'name: <bluez.*' \
    | awk '{print substr($2, 2, length($2)-2)}'
}


get_mac_device() {
  bt-device -l \
    | tail -n 1 \
    | awk '{ print substr($NF, 2, length($NF)-2) }'
}

mute_toggle() {
  check_enabled_or_die
  local dev_id=$(get_device_id)
  pactl set-sink-mute $dev_id toggle
}

set_volume() {
  check_enabled_or_die
  local dev_id=$(get_device_id)
  local level=$1
  pactl set-sink-volume $dev_id $level
}

is_bluetooth_enabled() {
  pacmd list-sinks | rg bluetooth &> /dev/null
}

choose_device() {
  bt-device -l \
    | fzf --header-lines=1 \
    | awk '{ print substr($NF, 2, length($NF)-2) }'
}

interactive_connect() {
  local mac=$(choose_device);
  echo -e "connect ${mac} \nquit" | bluetoothctl
}

disconnect() {
  local mac=$(get_mac_device)
  echo -e "disconnect ${mac} \nquit" | bluetoothctl
}

die() {
  printf "\n${C_B_RED}Error:${C_RESET} $@" >&2
  exit 1
}

check_enabled_or_die() {
  if ! is_bluetooth_enabled; then
    die 'bluetooth is not enabled or connected'
  fi
}


case $action in
  --set-volume) set_volume ${2};;
 --mute-toggle) mute_toggle;;
     --connect) interactive_connect;;
  --disconnect) disconnect;;
             *) die "invalid option '${@}'";;
esac