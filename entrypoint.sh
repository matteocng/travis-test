#!/bin/bash
# This script checks if "$@", the concatenated input argument, is a package.json
# script that yarn can run, in that case it runs yarn "$@", otherwise it just runs
# the supplied command as-is.
if [ -f "$(pwd)"/package.json ]; then
  YARNOUTPUT=$(yarn run --json 2> /dev/null)
  RESULT=$(echo "$YARNOUTPUT" | awk '/possibleCommands.+items.+"'"$*"'"/')
fi

if [ ! -z "$RESULT" ]; then
  exec yarn "$@"
  exit $?
fi

exec "$@"
