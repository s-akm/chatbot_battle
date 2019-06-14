#!/bin/bash -eu

function call_smalltalk() {
    curl -s "https://api.a3rt.recruit-tech.co.jp/talk/v1/smalltalk" \
      --data "query=$1" \
      --data "apikey=${API_KEY_SMALLTALK}" \
      | jq -r -R 'fromjson? | .results[].reply'
}

# main part
while :
do
    printf "\e[31m%s\e[m" "YOU>> "
    read text
    result1=$(call_smalltalk ${text})
    printf "\e[35m%s\e[m%s\n" "SMALLTALK>> " "${result1}"
done
