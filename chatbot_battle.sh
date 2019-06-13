#!bin/bash -eu

function call_userlocal() {
  curl -s "https://chatbot-api.userlocal.jp/api/chat" --data "message=$1" --data "key=${API_KEY_USERLOCAL}" | jq -r '.result'
}
function call_cotogoto() {
  curl -s 'https://app.cotogoto.ai/webapi/noby.json' --get --data "text=$1" --data "appkey=${API_KEY_COTOGOTO}" | jq -r '.text'
}

while :
do
    result=$(call_cotogoto ${result2:-${1:-"こんにちは。"}})
    printf "\e[33m%s\n\e[m" "COTOGOTO>> ${result}" || exit 1
    sleep 1
    result2=$(call_userlocal ${result})
    printf "\e[34m%s\n\e[m" "USERLOCAL>> ${result2}" || exit 2
    sleep 1
done
