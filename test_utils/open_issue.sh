#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

redmine_url=https://localhost

curl --insecur -v -x '' -u 69139917c128da6186de3439a8674b278cb494de:fake $redmine_url/channels/user:admin/post_msg.json -X POST -H 'Content-Type: application/json' -d "{\"msg\": {\"command\": \"open_url\", \"url\": \"$redmine_url\/issues\/1\"}}"
