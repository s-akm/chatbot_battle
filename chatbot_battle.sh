#!bin/bash -eu

SENTIMENT1=0
SENTIMENT2=0

trap judge EXIT

function call_userlocal() {
    curl -s "https://chatbot-api.userlocal.jp/api/chat" --data "message=$1" --data "key=${API_KEY_USERLOCAL}" | jq -r '.result'
}
function call_cotogoto() {
    curl -s 'https://app.cotogoto.ai/webapi/noby.json' --get --data "text=$1" --data "appkey=${API_KEY_COTOGOTO}" | jq -r '.text'
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
      --data "${json}" | jq -r '.documentSentiment.magnitude'
}
function judge() {
    if [ $(echo "${SENTIMENT1} > ${SENTIMENT2}" | bc) -eq 1 ]; then cowsay "COTOGOTO Wins!"; return; fi
    if [ $(echo "${SENTIMENT2} > ${SENTIMENT1}" | bc) -eq 1 ]; then cowsay "USERLOCAL Wins!"; return; fi
    cowsay "Draw!"
}

# main part
while :
do
    result1=$(call_cotogoto ${result2:-${1:-"こんにちは。"}})
    SENTIMENT1=$(echo "${SENTIMENT1} + $(analyze_sentiment ${result1})" | bc )
    printf "\e[33m%s\n\e[m" "COTOGOTO(${SENTIMENT1})>> ${result1}"

    result2=$(call_userlocal ${result1})
    SENTIMENT2=$(echo "${SENTIMENT2} + $(analyze_sentiment ${result2})" | bc )
    printf "\e[34m%s\n\e[m" "USERLOCAL(${SENTIMENT2})>> ${result2}"
done
