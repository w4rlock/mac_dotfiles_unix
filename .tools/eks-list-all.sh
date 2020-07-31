#!/usr/bin/env bash
_assume_rol='your_rol'
_aws_profile_to_fetch_accounts='fetch_account_rol'

# CMD ARGS
_script_name=$0
_filter_account=${1:-''}

_accounts_cache_file="./accounts.json"
_aws_cache_session="./session.json"
_clusters_cache_list="./clusters.list"
_fzf_select='.Accounts | .[] | (.Id + " -- " +.Name)'


C_BLUE=$(tput setaf 4)
C_GREEN=$(tput setaf 2)
C_RED=$(tput setaf 1)
C_B_BLUE="${T_BOLD}$(tput bold)$(tput setaf 4)"
C_B_GREEN="${T_BOLD}$(tput setaf 2)"
C_B_RED="${T_BOLD}$(tput setaf 1)"
C_RESET=$(tput sgr0)
T_BOLD=$(tput bold)


info() {
  local left="${C_B_BLUE}[${C_RESET}${T_BOLD} ** ${C_B_BLUE}]${C_RESET} -"
  local msg="$@"
  printf "%s %s\n" "${left}" "$T_BOLD${msg}${C_RESET}"
  sleep .25
}



check_cache_file() {
  if ! test -s ${_accounts_cache_file}; then
    info "Cache file not found..."
    info "Fetching accounts..."

    aws organizations list-accounts \
      --profile $_aws_profile_to_fetch_accounts > $_accounts_cache_file
  fi
}


load_session() {
  if ! test -s $_aws_cache_session; then
    return 1
  fi

  local _session=$(cat $_aws_cache_session)
  local _access_key=$(echo $_session | jq -r '.Credentials | .AccessKeyId')
  local _secret_key=$(echo $_session | jq -r '.Credentials | .SecretAccessKey')
  local _token=$(echo $_session | jq -r '.Credentials | .SessionToken')
  local _account_label=$(echo $_session | jq -r '.AssumedRoleUser | .Arn' | cut -d'/' -f3)


  export AWS_ACCESS_KEY_ID=$_access_key
  export AWS_SECRET_ACCESS_KEY=$_secret_key
  export AWS_SESSION_TOKEN=$_token
  export AWS_SESSION_NAME=$_account_label
}

# if has assumed a rol into shell
# cannot assumed another
# it necessary clear the session
aws_logout() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  unset AWS_SESSION_NAME
  rm $_aws_cache_session &> /dev/null
}


assume_role() {
  local _account=$1
  if [[ "${_account}" == "" ]]; then
    return
  fi

  local _id=$(echo $_account | awk '{print $1}')
  local _name=$(echo $_account | awk '{print $3}')

  aws_logout
  info "Logging into account ${C_RED}'${_name}' ${C_RESET}..."

  local role="arn:aws:iam::${_id}:role/${_assume_rol}"
   aws sts assume-role \
     --role-arn "${role}" \
     --role-session-name "aws@${_name}" > $_aws_cache_session \
     --duration-seconds 3600
}


get_accounts() {
  cat $_accounts_cache_file \
    | jq -r "${_fzf_select}" \
    | sort -k 3
}


list_clusters() {
  aws eks list-clusters --region us-east-1 | jq -r ".clusters | .[]"
}


save_cluster_info() {
  local account=$1
  local clusters=$(list_clusters)

  while IFS= read -r cluster; do
    test -z $cluster && continue

    info "Cluster found: '${cluster}'"
    echo "${account} -- ${cluster}" >> $_clusters_cache_list
  done <<< "$clusters"
}

check_cache_file
accounts=$(get_accounts)
while IFS= read -r account; do
  assume_role "${account}"
  load_session
  save_cluster_info "${account}"
done <<< "$accounts"
