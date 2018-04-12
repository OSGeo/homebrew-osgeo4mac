#!/usr/bin/env bash
set -e



if [[ -n ${TRAVIS_MANUAL_FORMULAE} ]]; then
  echo "${TRAVIS_MANUAL_FORMULAE}"
fi

if [[ ! -z  $TRAVIS_PULL_REQUEST_BRANCH  ]]; then
  # if on a PR, just analyze the changed files
    FILES=$(git diff --diff-filter=AM --name-only $(git merge-base HEAD ${TRAVIS_BRANCH} ) )
elif [[ ! -z  $TRAVIS_COMMIT_RANGE  ]]; then
  FILES=$(git diff --diff-filter=AM --name-only ${TRAVIS_COMMIT_RANGE/.../..} )
else
  FILES=
fi

FORMULAS=$(sed -n -E 's#^Formula/(.+)\.rb$#\1#p' <<< $FILES)
if [[ -n ${FORMULAS} ]]; then
  echo ${FORMULAS}
fi
