#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac travis ci - after_script.sh
#    ---------------------
#    Date                 : Dec 2016
#    Copyright            : (C) 2016 by Boundless Spatial, Inc.
#    Author               : Larry Shaffer
#    Email                : lshaffer at boundlessgeo dot com
###########################################################################
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
###########################################################################

# Setup Git configuration
COMMIT_USER=$(git log --format='%an' ${CIRCLE_SHA1}^\!)
COMMIT_EMAIL=$(git log --format='%ae' ${CIRCLE_SHA1}^\!)
git config user.name "Geo Ninja"
git config user.email "qgisninja@gmail.com"
REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

Checkout on the proper branch
see https://gist.github.com/mitchellkrogza/a296ab5102d7e7142cc3599fca634203
head_ref=$(git rev-parse HEAD)
if [[ $? -ne 0 || ! $head_ref ]]; then
    err "failed to get HEAD reference"
    return 1
fi
branch_ref=$(git rev-parse "$CIRCLE_BRANCH")
if [[ $? -ne 0 || ! $branch_ref ]]; then
    err "failed to get $CIRCLE_BRANCH reference"
    return 1
fi
if [[ $head_ref != $branch_ref ]]; then
    msg "HEAD ref ($head_ref) does not match $CIRCLE_BRANCH ref ($branch_ref)"
    err "someone may have pushed new commits before this build cloned the repo"
    return 1
fi
if ! git checkout "$CIRCLE_BRANCH"; then
    err "failed to checkout $CIRCLE_BRANCH"
    return 1
fi

# Build the actual bottles
# In Travis, this used to be part of the deploy phase, but now it needs to run as part of the original build process, but only on master.
mkdir /tmp/bottles
cd /tmp/bottles

BUILT_BOTTLES=

pushd /tmp/bottles
  BOTTLE_ROOT=https://dl.bintray.com/homebrew-osgeo/osgeo-bottles
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."
    brew bottle --verbose --json --root-url=${BOTTLE_ROOT} osgeo/osgeo4mac/${f}

    for art in ${f}*.sierra.bottle.*; do
        # Remove double dashes introduced by the latest changes to Homebrew bottling.
        # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
        # Move the sierra bottle and json file
        mv ${art} ${art/--/-}
    done

    # temporary duplication of 10.3-Xcode-10.x-built bottles to 10.4 bottles
    # Do the bottle duplication per formula, so we can merge the changes
    for art in ${f}*.high_sierra.bottle.*; do
      new_name=${art/.high_sierra./.mojave.}
      # Remove double dashes introduced by the latest changes to Homebrew bottling.
      # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
      cp -a ${art} ${new_name/--/-}
      # Move the high_sierra bottle and json file
      mv ${art} ${art/--/-}
    done
    for json in ${f}*.mojave.bottle*.json; do
      sed -i '' s@high_sierra@mojave@g ${json}
    done

    echo "Updating changed formula ${f} with new bottles..."

    # Do Merge bottles with the formula
    # Don't commit anything, we'll do that after updating all the formulae
    # Catch the eror and store it to a variable
    if result=$(brew bottle --merge --write --no-commit ${f}*.json 2>&1); then
      BUILT_BOTTLES="$BUILT_BOTTLES ${f}"
    else
      # If there's an error, remove the json and bottle files, we don't want them anymore.
      echo "Unable to bottle ${f}"
      echo $result
      rm ${f}*.json
      rm ${f}*.tar.gz
    fi
  done
popd
