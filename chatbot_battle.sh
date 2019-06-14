#!/bin/bash -eu

SENTIMENT_COTOGOTO=0
SENTIMENT_USERLOCAL=0
SENTIMENT_SMALLTALK=0

trap total EXIT

function call_userlocal() {
    curl -s "https://chatbot-api.userlocal.jp/api/chat" \
      --data "message=$1" \
      --data "key=${API_KEY_USERLOCAL}" \
      | jq -r -R 'fromjson? | .result'
}
function call_cotogoto() {
    curl -s 'https://app.cotogoto.ai/webapi/noby.json' \
      --get \
      --data "text=$1" \
      --data "appkey=${API_KEY_COTOGOTO}" \
      | jq -r -R 'fromjson? | .text'
}
function call_smalltalk() {
    curl -s "https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk" \
      --data "query=$1" \
      --data "apikey=${API_KEY_SMALLTALK}" \
      | jq -r -R 'fromjson? | .results[].reply'
}
function analyze_sentiment() {
    json=$(cat << EOS
{
  "document": {
    "type": "PLAIN_TEXT",
    "language": "JA",
    "content": "${1}"
  },
  "encodingType": "UTF8"
}
EOS
    )
    curl -s -H 'Content-Type:application/json' \
      "https://language.googleapis.com/v1/documents:analyzeSentiment?key=${API_KEY_CNL}" \
      --data "${json}" \
      | jq -r '.documentSentiment.magnitude'
}
function total() {
    printf "\n\e[31m%s\e[m\n" "-------- END OF CONVERSATION --------"
    printf "%s\n" "# SENTMENTAL MAGNITUDE"
    printf "\e[33m%s\e[m%s\n" "COTOGOTO: " "${SENTIMENT_COTOGOTO}"
    printf "\e[34m%s\e[m%s\n" "USERLOCAL: " "${SENTIMENT_USERLOCAL}"
    printf "\e[35m%s\e[m%s\n" "SMALLTALK: " "${SENTIMENT_SMALLTALK}"
}

# main part
while :
do
    result1=$(call_cotogoto ${result3:-${1:-"こんにちは。"}}) || exit 1
    SENTIMENT_COTOGOTO=$(echo "${SENTIMENT_COTOGOTO} + $(analyze_sentiment ${result1})" | bc )
    printf "\e[33m%s\e[m%s\n" "COTOGOTO(${SENTIMENT_COTOGOTO})>> " "${result1}"

    result2=$(call_userlocal ${result1}) || exit 1
    SENTIMENT_USERLOCAL=$(echo "${SENTIMENT_USERLOCAL} + $(analyze_sentiment ${result2})" | bc )
    printf "\e[34m%s\e[m%s\n" "USERLOCAL(${SENTIMENT_USERLOCAL})>> " "${result2}"

    result3=$(call_smalltalk ${result2}) || exit 1
    SENTIMENT_SMALLTALK=$(echo "${SENTIMENT_SMALLTALK} + $(analyze_sentiment ${result3})" | bc )
    printf "\e[35m%s\e[m%s\n" "SMALLTALK(${SENTIMENT_SMALLTALK})>> " "${result3}"
done
