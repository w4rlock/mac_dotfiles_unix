run_segment() {
  local _icon=${ICON_PROCESS:-" "}
  local icon="#[fg=default]${_icon}#[fg=green]"
  ps aux | wc -l \
    | sed "s/ //g" \
    | sed -ne "s/.*/${icon} &/p"
  return 0
}
