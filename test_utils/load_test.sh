#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

issue_id=1

api_token=69139917c128da6186de3439a8674b278cb494de

redmine_url=http://localhost:3000

count=0
while [[ $count -lt 10 ]]
do
	curl -v -u $api_token:fake -x '' $redmine_url/issues/$issue_id.json -X PUT -H 'Content-Type: application/json' -d "{\"issue\": {\"notes\": \"note $count\"}}"
	sleep 1
	count=$((count+1))
done
