#!/usr/bin/env bash
set -e


# manually added by env var. Will not be filtered by skip-formulas.txt
# If manual formulae are specified, changed files will be ignored
# This avoids rebuilding bottles when triggered against master
if [[ -n ${CI_MANUAL_FORMULAE} ]]; then
	echo "${CI_MANUAL_FORMULAE}"
else

	if [[ ! -z  $CIRCLE_PULL_REQUEST  ]]; then
		# if on a PR, just analyze the changed files
		FILES=$(git diff --diff-filter=AM --name-only $(git merge-base HEAD ${CIRCLE_BRANCH} ) )
	elif [[ ! -z  $COMMIT_RANGE  ]]; then
      # Get the commit range for the build
      COMMIT_RANGE=$(echo "${CIRCLE_COMPARE_URL}" | cut -d/ -f7)

      if [[ $COMMIT_RANGE != *"..."* ]]; then
          COMMIT_RANGE="${COMMIT_RANGE}...${COMMIT_RANGE}"
		FILES=$(git diff --diff-filter=AM --name-only ${COMMIT_RANGE/.../..} )
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
  comm -1 -3 <(cat .circleci/skip-formulas.txt | sort -u ) <(echo ${FORMULAS} | tr ' ' '\n' | sort -u )
fi
