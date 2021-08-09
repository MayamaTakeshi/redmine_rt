#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function usage() {
cat <<EOF

Usage: $0 redmine_url api_token 'channel_id' 'notification_data'
Ex:    $0 http://localhost:3000 3b188399dbca8b834145cf9ffe15f2fed8c3e3a6 "user:admin" '{"title": "Call from Pablo Picasso", "message": "Impatient customer. Hurry up!", "iconUrl": "https://cdn.dribbble.com/users/4385/screenshots/344648/picasso_icon.jpg", "buttons": [{"title": "Open customers details page", "command": "post_msg", "data": {"channel_name": "user:admin", "msg": {"command": "open_url", "data": {"url": "https://en.wikipedia.org/wiki/Pablo_Picasso"}}}}, {"title": "Open Issue", "command": "open_url", "data": {"url": "http://localhost:3000/issues/4"}}]}' 
EOF
}


if [[ $# != 4 ]]
then
	usage
	exit 1;
fi

redmine_url=$1
api_token=$2
channel_id=$3
notification_data=$4

curl --insecure -v -x '' -u $api_token:fake $redmine_url/channels/$channel_id/post_msg.json -X POST -H 'Content-Type: application/json' -d "{\"command\": \"show_notification\", \"data\": $notification_data}"
