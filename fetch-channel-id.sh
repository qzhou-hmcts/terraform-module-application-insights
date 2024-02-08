#!/usr/bin/env bash

if ! command -v yq &> /dev/null; then
    apt update
    apt install yq -y
fi

if ! command -v jq &> /dev/null; then
    apt update
    apt install jq -y
fi


eval "$(jq -r '@sh "PRODUCT=\(.product)"')"

# PRODUCT="sssss"

# convert yaml to json
cnp_json=$(curl -s https://raw.githubusercontent.com/hmcts/cnp-jenkins-config/master/team-config.yml | yq e -o=json)


channel_id=$(echo "$cnp_json" | jq --arg PRODUCT "$PRODUCT" -r '.[$PRODUCT] | .slack.channel_id')


if [ "$channel_id" = "null" ]; then
  sds_json=$(curl -s https://raw.githubusercontent.com/hmcts/sds-jenkins-config/master/team-config.yml | yq e -o=json)
  channel_id=$(echo "$sds_json" | jq --arg PRODUCT "$PRODUCT" -r '.[$PRODUCT] | .slack.channel_id')
  
  if [ "$channel_id" = "null" ]; then
    channel_id="NOT FOUND"
  fi
  # echo $channel_id
fi

echo -n "{\"channel_id\":\"$channel_id\"}"