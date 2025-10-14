#!/usr/bin/env bash

set -eu

OPTIONS=$(getopt --longoptions allow-temp,header-length: --options "" -- "$@")
unset COMMIT_VALIDATOR_ALLOW_TEMP COMMIT_VALIDATOR_NO_REVERT_SHA1

eval set -- $OPTIONS
while true; do
  case "$1" in
    --allow-temp ) COMMIT_VALIDATOR_ALLOW_TEMP=1; shift ;;
    --no-revert-sha1 ) COMMIT_VALIDATOR_NO_REVERT_SHA1=1; shift ;;
    --header-length ) GLOBAL_MAX_LENGTH="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck source=validator.sh
source "$DIR/validator.sh"


if [[ "$1" == *MERGE_MSG ]]
then
  # ignore merge message (merge with --no-ff without conflict)
  exit
fi

# removing comment lines from message
MESSAGE=$(sed '/^#/d' "$1")

FIRST_WORD=${MESSAGE%% *}
if [[ "${FIRST_WORD,,}" == merge ]]
then
   # ignore merge commits (merge after conflict resolution)
  exit

fi

# print message so you don't lose it in case of errors
# (in case you are not using `-m` option)
echo "Options: "
echo "  TEMP=${COMMIT_VALIDATOR_ALLOW_TEMP:-}"
echo "  NO_REVERT_SHA1=${COMMIT_VALIDATOR_NO_REVERT_SHA1:-}"
printf "checking commit message:\n\n#BEGIN#\n%s\n#END#\n\n" "$MESSAGE"

validate "$MESSAGE"
