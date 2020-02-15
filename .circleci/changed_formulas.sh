#!/usr/bin/env bash
set -e

if [ "$CIRCLE_BRANCH" != "master" ]; then
# manually added by env var. Will not be filtered by skip-formulas.txt
# If manual formulae are specified, changed files will be ignored
# This avoids rebuilding bottles when triggered against master
if [[ -n ${CI_MANUAL_FORMULAE} ]]; then
	echo "${CI_MANUAL_FORMULAE}"
else

	  if [[ ! -z  $CIRCLE_PULL_REQUEST  ]]; then
		# if on a PR, just analyze the changed files
		FILES=$(git diff --diff-filter=AM --name-only $(git merge-base origin/master ${CIRCLE_BRANCH} ) )
	else
        # Get the commit range for the build
        # For workflows, we can't use the CIRCLE_COMPARE_URL feature, so we do it by manualy diffing the branch
#      COMMIT_RANGE=$(echo "${CIRCLE_COMPARE_URL}" | cut -d/ -f7)

#      if [[ $COMMIT_RANGE != *"..."* ]]; then
#          COMMIT_RANGE="${COMMIT_RANGE}...${COMMIT_RANGE}"
        #      fi
        # Since CircleCI doesn't currently support getting a range of commits when running as a workflow, we're stuck just looking at the changes from the most recent commit.
        # This means we always needs to rebase or squash and merge, which is mostly what we do anyways.
		    #FILES=$(git diff --diff-filter=AM --name-only master...${CIRCLE_BRANCH} )
        	FILES=$(git diff --diff-filter=AM --name-only master^1 )
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
fi
