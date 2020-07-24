#!/usr/bin/env bash
TOKEN=${TOKEN:?'ERROR... USE: export TOKEN=some_token'}
URL=${1:?'url argument is required'}

curl -sk -vv \
-H 'Accept: application/json' \
-H "Authorization: Bearer ${TOKEN}" \
$URL