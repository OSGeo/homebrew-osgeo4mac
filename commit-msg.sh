#!/usr/bin/env bash

if [[ ! -a .ciignore ]]; then
	exit # If .ciignore doesn't exists, just quit this Git hook
fi

# Load in every file that will be changed via this commit into an array
changes=( `git diff --name-only --cached` )

# Load the patterns we want to skip into an array
mapfile -t blacklist < .ciignore

for i in "${blacklist[@]}"
do
	# Remove the current pattern from the list of changes
	changes=( ${changes[@]/$i/} )

	if [[ ${#changes[@]} -eq 0 ]]; then
		# If we've exhausted the list of changes before we've finished going 
		# through patterns, that's okay, just quit the loop
		break
	fi
done

if [[ ${#changes[@]} -gt 0 ]]; then
	# If there's still changes left, then we have stuff to build, leave the commit alone.
	exit
fi

# Prefix the commit message with "[skip ci]"
sed -i '1s/^/[skip ci] /' "$1"

