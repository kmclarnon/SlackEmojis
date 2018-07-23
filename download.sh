#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

echo "Enter your slack legacy token"
read legacy_token

echo "Enter target directory"
read target_dir

team_name=$(curl -s "https://slack.com/api/team.info?token=${legacy_token}" | jq -r '.team.name')

read -p "Fetch emoji from ${team_name} (y/n)?" -n 1 -r do_download;
echo    # (optional) move to a new line
if [[ ! ${do_download} =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

mkdir -p ${target_dir}

curl -s "https://slack.com/api/emoji.list?token=${legacy_token}" | jq -r '.emoji | to_entries[] | [.key, .value] | @tsv' |
  while IFS=$'\t' read -r key value; do
    if [[ ! ${value} =~ ^alias:.*$ ]]
    then
      echo "Found entry ${key} - ${value}"
      filename=$(basename ${value})
      extension="${filename##*.}"
      curl -s ${value} --output "${target_dir}/${key}.${extension}"
    fi
  done

