#!/bin/bash

# if current branch does not start with gh - then return 0
if [[ ! $BUILDKITE_BRANCH =~ ^gh.* ]]; then
  sleep 120
  echo "Not a gh-pages branch, skipping deploy"
  exit 0
fi

val=$(buildkite-agent meta-data get "pof") || true
echo "Val: $val"

if [[ $val == "1" ]]; then
  exit 1
fi

exit 0
