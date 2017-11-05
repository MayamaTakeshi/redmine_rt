#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function usage() {
cat <<EOF

Usage: $0 redmine_url api_token issue_id user
Ex:    $0 http://localhost:3000 3b188399dbca8b834145cf9ffe15f2fed8c3e3a6 4 admin
EOF
}


if [[ $# != 4 ]]
then
	usage
	exit 1;
fi

redmine_url=$1
api_token=$2
issue_id=$3
user=$4

curl --insecure -v -x '' -u $api_token:fake $redmine_url/channels/user:$user/post_msg.json -X POST -H 'Content-Type: application/json' -d "{\"command\": \"open_url\", \"data\": {\"url\": \"$redmine_url\/issues\/$issue_id\"}}"
