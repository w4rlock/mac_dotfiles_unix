run_segment() {
  # load aws env vars to load costs
  local today=$(date +'%F')
  local cacheFile="/tmp/${today}.dolar.cache"
  local update_period=3600

  if test -s $cacheFile; then
    last_update=$(stat -f "%m" ${cacheFile})
    time_now=$(date +%s)
    up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)

    if [ "$up_to_date" -eq 1 ]; then
      cat $cacheFile | sed 's/USD\$ /  /g' | sed 's/,00//g'
      return 0
    fi
  fi

  ~/.tools/values-stat.sh blue | tail -1 > $cacheFile
  return 0
}
