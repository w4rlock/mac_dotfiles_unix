run_segment() {
    local today="$(date +'%F')"
    local cacheFile="/tmp/${today}.aws.costs.cache"

    [ -f $cacheFile ] \
      && cat $cacheFile \
      && return $?

    icon=${AWS_COSTS_ICON:-"💰"}

    python $HOME/.tools/costs.py \
      | awk '{ print $2 }' \
      | sed -ne "s/.*/${icon} &/p" \
      | tee $cacheFile

    return 0
}
