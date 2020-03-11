#!/usr/bin/env bash

# amazon-eks-node-1.14-v20200228 = ami-08ac00d99a673bad0
# amazon-eks-node-1.13-v20200228 - ami-0973bc1f558f5def1


set -e

readonly EDITOR=${EDITOR:-vim}
readonly LAUNCH_CONF_TPL='CurrentLC.json'



__install_deps() {
  local pkg_mng="${@}"

  for dep in jq sponge fzf; do
    which $dep &> /dev/null || {
      echo "Installing pkg \"$dep\"..."
      $pkg_mng $dep
    }
  done
}



check_install_dependencies() {
  if which apt &> /dev/null; then
    __install_deps "apt install"
  elif which brew &> /dev/null; then
    __install_deps "brew install"
  fi
}




die() {
  echo "$@" >&2
  exit 1
}



# LAUNCH CONFIGURATION TEMPLATE BASE TO CLONE
choose_base_launch_conf() {
  sleep 1
  local launch_conf_name=$(aws autoscaling describe-launch-configurations \
    | jq -r '.LaunchConfigurations | .[] | .LaunchConfigurationName' \
    | fzf
  )

  [ "${launch_conf_name}" == "" ] && die "nothing to do.. exiting"
  echo $launch_conf_name
}



# FETCH TEMPLATE BASE AND COPY
fetch_base_launch_conf_json() {
  local launch_conf_name=$1

  aws autoscaling describe-launch-configurations \
    --launch-configuration-names ${launch_conf_name} \
    --query "LaunchConfigurations[0]" > $LAUNCH_CONF_TPL

  cp $LAUNCH_CONF_TPL ${LAUNCH_CONF_TPL}.old.original &> /dev/null
}



# REPLACE PROPERTY WITH VALUE
# RUN EXPRESSION
jq_write_tpl() {
  jq "$@" $LAUNCH_CONF_TPL | sponge $LAUNCH_CONF_TPL
}




update_launch_conf_json() {
  local lc=$1
  echo "Updating launch configuration json..."
  # amazon-eks-node-1.14-v20200228
  jq_write_tpl '.ImageId = "ami-08ac00d99a673bad0"'
  jq_write_tpl '.InstanceType = "t3a.medium"'
  jq_write_tpl '.BlockDeviceMappings[0].Ebs.VolumeSize = 50'
  # remove additionals fields
  # is important to remote it this fields
  jq_write_tpl 'del(.CreatedTime, .LaunchConfigurationARN, .KernelId, .RamdiskId, .BlockDeviceMappings[0].Ebs.SnapshotId)'

  read -p "New launch configuration name [default=${lc}-2] " answer
  new_lc=${answer:-${lc}-2}

  jq --arg val $new_lc '.LaunchConfigurationName = $val' $LAUNCH_CONF_TPL | sponge $LAUNCH_CONF_TPL
  export NEW_LC=$new_lc
}



create_new_launch_conf() {
  aws autoscaling create-launch-configuration \
    --cli-input-json file://$(pwd)/$LAUNCH_CONF_TPL \
    --user-data \
    file://<(jq .UserData $(pwd)/${LAUNCH_CONF_TPL} --raw-output | base64 --decode)
}




main() {
  echo "Checking tools dependencies..."
  check_install_dependencies

  echo "Fetching launch configurations..."
  lc=$(choose_base_launch_conf)
  fetch_base_launch_conf_json $lc
  update_launch_conf_json $lc

  echo "Please verify your new Launch Conf template..."
  sleep 2


  $EDITOR $LAUNCH_CONF_TPL


  create_new_launch_conf
  as_group=$(aws autoscaling describe-auto-scaling-groups | jq -r --arg old_lc $lc \
    '.AutoScalingGroups | .[] | select(.LaunchConfigurationName == $old_lc) | .AutoScalingGroupName')

  [ -z "${as_group}" ] && die "Error: the autoscaling group for launch configuration \"${lc}\" is missing..."

  # ASSING OLD AUTO SCALING GROUP LAUNCH CONFIGURATION TO NEW
  # LAUNCH CONFIGURATION AND CHANGE SIZES
  # TO TERMINATE OLD EC2 INSTANCES
  aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name "$as_group" \
    --launch-configuration-name "$NEW_LC" \
    --min-size 0 \
    --desired-capacity 0 \
    --max-size 2



  echo "Checking autoscaling activity..."
  sleep 4
  aws autoscaling describe-scaling-activities \
    --auto-scaling-group-name $as_group | jq -r '.Activities | .[] | .Description'


  #aws eks update-cluster-version --name $(fzf....) --kubernetes-version 1.13
  #aws eks update-cluster-version --name $(fzf....) --kubernetes-version 1.14
}


main $@





