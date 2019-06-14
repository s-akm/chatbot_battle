#!/bin/bash -eu

function call_userlocal() {
    curl -s "https://chatbot-api.userlocal.jp/api/chat" \
      --data "message=$1" \
      --data "key=${API_KEY_USERLOCAL}" \
      | jq -r -R 'fromjson? | .result'
}

# main part
while :
do
    printf "\e[31m%s\e[m" "YOU>> "
    read text
    result1=$(call_userlocal ${text})
    printf "\e[34m%s\e[m%s\n" "USERLOCAL>> " "${result1}"
done
