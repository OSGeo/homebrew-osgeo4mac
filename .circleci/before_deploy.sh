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

# ls -lah /tmp/workspace/bottles/

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

# BUILT_BOTTLES=
# pushd /tmp/workspace/bottles/
#   for f in ${CHANGED_FORMULAE};do
#     echo "Updating changed formula ${f} with new bottles..."
#
#     # Do Merge bottles with the formula
#     # Don't commit anything, we'll do that after updating all the formulae
#     # Catch the eror and store it to a variable
#     if result=$(brew bottle --merge --write --no-commit ${f}*.json 2>&1); then
#       BUILT_BOTTLES="$BUILT_BOTTLES ${f}"
#     else
#      # If there's an error, remove the json and bottle files, we don't want them anymore.
#      echo "Unable to bottle ${f}"
#      echo $result
#      rm ${f}*.json
#      rm ${f}*.tar.gz
#     fi
#   done
# popd

# Set up the keys
# Decrypt the circle_deploy_key.enc key into /tmp/circle_deploy_key
# openssl aes-256-cbc -d -K $REPO_ENC_KEY -iv $REPO_ENC_IV -in circle_deploy_key.enc -out /tmp/circle_deploy_key
# Make sure only the current user can read the private key
# chmod 600 /tmp/circle_deploy_key
# Create a script to return the passphrase environment variable to ssh-add
# echo 'echo ${SSH_PASSPHRASE}' > /tmp/askpass && chmod +x /tmp/askpass
# Start the authentication agent
# eval "$(ssh-agent -s)"
# Add the key to the authentication agent
# brew install util-linux # for setsid
# DISPLAY=":0.0" SSH_ASKPASS="/tmp/askpass" setsid ssh-add /tmp/circle_deploy_key </dev/null
# checkout, restore_cache, run: yarn install, save_cache, etc.
# Run semantic-release after all the above is set.

# cd ${HOMEBREW_REPOSITORY}/Library/Taps/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}

# Now do the commit and push

# git add -vA Formula/*.rb
# git commit -m "Updated bottles for: ${BUILT_BOTTLES}

# Committed for ${COMMIT_USER}<${COMMIT_EMAIL}> - [ci skip]"

# Now that we're all set up, we can push.
# git push ${SSH_REPO} $CIRCLE_BRANCH
