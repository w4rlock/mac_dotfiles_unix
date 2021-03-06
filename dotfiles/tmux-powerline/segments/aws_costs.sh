run_segment() {
  # load aws env vars to load costs
  source _aws-naranja --restore &> /dev/null || true

  local today="$(date +'%F')"
  local cacheFile="/tmp/${today}.${AWS_SESSION_NAME}.costs.cache"

  if test -s $cacheFile; then
    if grep 'to' $cacheFile &> /dev/null; then
      echo
      return 1
    fi

    cat $cacheFile
    return 0
  fi

  icon=${AWS_COSTS_ICON:-" "}
  python $HOME/.tools/costs.py \
    | awk '{ print $2 }' \
    | sed -ne "s/.*/${icon} &/p" > $cacheFile

  return 0
}
