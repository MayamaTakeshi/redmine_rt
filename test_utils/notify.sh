#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

function usage() {
cat <<EOF

Usage: $0 redmine_url api_token 'channel_id' 'notification_data'
Ex:    $0 http://localhost:3000 69139917c128da6186de3439a8674b278cb494de "user:admin" '{"title": "Call from Pablo Picasso", "message": "Impatient customer. Hurry up!", "imageUrl": "https://cdn.dribbble.com/users/4385/screenshots/344648/picasso_icon.jpg"}'
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

curl --insecure -v -x '' -u $api_token:fake $redmine_url/channels/$channel_id/post_msg.json -X POST -H 'Content-Type: application/json' -d "{\"msg\": {\"command\": \"show_notification\", \"data\": $notification_data}}"
