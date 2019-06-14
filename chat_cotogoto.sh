#!/bin/bash -eu

function call_cotogoto() {
    curl -s 'https://app.cotogoto.ai/webapi/noby.json' \
      --get \
      --data "text=$1" \
      --data "appkey=${API_KEY_COTOGOTO}" \
      | jq -r -R 'fromjson? | .text'
}

# main part
while :
do
    printf "\e[31m%s\e[m" "YOU>> "
    read text
    result1=$(call_cotogoto ${text})
    printf "\e[33m%s\e[m%s\n" "COTOGOTO>> " "${result1}"
done
