#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function usage() {
cat <<EOF

Usage: $0 redmine_url api_token issue_id user
Ex:    $0 http://localhost:3000 69139917c128da6186de3439a8674b278cb494de 1 admin
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

curl --insecure -v -x '' -u $api_token:fake $redmine_url/channels/user:$user/post_msg.json -X POST -H 'Content-Type: application/json' -d "{\"msg\": {\"command\": \"open_url\", \"url\": \"$redmine_url\/issues\/$issue_id\"}}"
