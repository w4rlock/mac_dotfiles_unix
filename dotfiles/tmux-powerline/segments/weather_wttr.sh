run_segment() {
  # load aws env vars to load costs
  local cacheFile="/tmp/tmux.weather.cache"
  local update_period=600

  if test -s $cacheFile; then
    last_update=$(stat -f "%m" ${cacheFile})
    time_now=$(date +%s)
    up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)

    if [ "$up_to_date" -eq 1 ]; then
      icon='#[fg=blue]#[fg=red] '
      cat $cacheFile | sed -ne "s/.*/${icon} &/p"
      return 0
    fi

  fi

  #TODO: readme https://wttr.in/:help
  # leemos la line 2 y nos quedamos con las ultimas 2 columnas
  curl -s "wttr.in?0QT" | sed -n '2p' | awk '{print $(NF-1)$NF}' > $cacheFile
  return 0
}
