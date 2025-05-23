#!/usr/bin/env bash

Font_RED='\033[91m'
Font_CLEAR='\033[0m'

VALID_TYPES=(feat fix refactor style chore test build docs)

MSG_FILE="$1"
COMMIT_MSG="$(<"$MSG_FILE")"

if [[ "$COMMIT_MSG" =~ ^Merge\ (branch|pull\ request) ]]; then
  exit 0
fi

TYPE=$(echo "$COMMIT_MSG" | cut -d':' -f1 | sed 's/ *$//')

# TYPE 유효성 검사
if ! printf '%s\n' "${VALID_TYPES[@]}" | grep -xq "$TYPE"; then
  printf "${Font_RED}[${TYPE}] 는 허용되지 않는 TYPE 입니다.${Font_CLEAR}\n"
  echo "👉 사용 가능한 TYPE: ${VALID_TYPES[*]}"
  exit 1
fi

if ! [[ "$COMMIT_MSG" =~ : ]]; then
  printf "${Font_RED}형식이 올바르지 않습니다. ':'(콜론)을 포함해야 합니다. 예: type: 메시지${Font_CLEAR}\n"
  exit 1
fi

if grep -qE '[[:alnum:]]\ :' <<< "$COMMIT_MSG"; then
  printf "${Font_RED}TYPE 뒤에 공백이 있습니다. 예: type: 메시지${Font_CLEAR}\n"
  exit 1
fi

if grep -qE ':[^[:space:]]' <<< "$COMMIT_MSG"; then
  printf "${Font_RED}콜론 다음에 공백이 필요합니다. 예: type: 메시지${Font_CLEAR}\n"
  exit 1
fi

BODY=$(echo "$COMMIT_MSG" | cut -d':' -f2- | sed 's/^ *//')
if [[ -z "$BODY" ]]; then
  printf "${Font_RED}커밋 메시지 본문이 비어 있습니다.${Font_CLEAR}\n"
  exit 1
fi

exit 0
