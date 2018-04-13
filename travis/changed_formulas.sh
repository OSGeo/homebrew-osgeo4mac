#!/usr/bin/env bash
set -e


# manually added by env var. Will not be filtered by skip-formulas.txt
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

FORMULAS=
for f in $FILES;do
  FORMULAS="$FORMULAS $(echo $f | sed -n -E 's#^Formula/(.+)\.rb$#\1#p')"
done

# keep formulas only
#FORMULAS=$(sed -n -E 's#^Formula/(.+)\.rb$#\1#p' <<< $FILES)
# skip formulas
comm -1 -3 travis/skip-formulas.txt <(echo ${FORMULAS} | tr ' ' '\n' )
