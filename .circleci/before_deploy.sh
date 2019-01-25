#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac travis ci - before_deploy.sh
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

set -e

ls -lah bottles/
# Setup Git configuration
COMMIT_USER=$(git log --format='%an' ${CIRCLE_SHA1}^\!)
COMMIT_EMAIL=$(git log --format='%ae' ${CIRCLE_SHA1}^\!)
git config user.name "Geo Ninja"
git config user.email "qgisninja@gmail.com"
REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

# Checkout on the proper branch
# see https://gist.github.com/mitchellkrogza/a296ab5102d7e7142cc3599fca634203
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

# Build the bottles
BUILT_BOTTLES=

pushd bottles
  BOTTLE_ROOT=https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/bottles
  for f in ${CHANGED_FORMULAE};do
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

# Set up the keys
openssl aes-256-cbc -iv "${ENCRYPTION_IV}" -K "${ENCRYPTION_KEY}" -d -in ../ci_deploy_key.enc -out ../deploy_key
ls .
chmod 600 ../deploy_key
eval `ssh-agent -s`
ssh-add ../deploy_key

# Now do the commit and push

git add -vA Formula/*.rb
git commit -m "Updated bottles for: ${BUILT_BOTTLES}

Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
[ci skip]"

git push git@github.com:osgeo/homebrew-osgeo4mac.git master

echo "Upload bottles for ${f}"

# Now do the commit and push
git add -vA ./bottles/*.tar.gz
git add -vA ./bottles/*.json
git commit -m "Updated bottle for: ${BUILT_BOTTLES}

Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
[ci skip]"

git push git@github.com:osgeo/homebrew-osgeo4mac.git bottles
