#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


function usage() {
cat <<EOF

Usage: $0 redmine_url api_token issue_id interval
Ex:    $0 http://localhost:3000 69139917c128da6186de3439a8674b278cb494de 1 5
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
interval=$4

count=0
while [[ 1 ]]
do
	curl -v --insecure -u $api_token:fake -x '' $redmine_url/issues/$issue_id.json -X PUT -H 'Content-Type: application/json' -d "{\"issue\": {\"notes\": \"note $count\"}}"
	sleep $interval

	for journal_id in `curl -s --insecure -u $api_token:fake -x '' $redmine_url/issues/$issue_id.json?include=journals | jq .issue.journals[].id`
	do
		echo Deleting journal $journal_id
		curl -v --insecure -u $api_token:fake -x '' $redmine_url/journals/$journal_id.json -X DELETE
		sleep $interval
	done
		
	sleep $interval

	count=$((count+1))
done
