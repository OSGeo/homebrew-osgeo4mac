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

cd ${TRAVIS_BUILD_DIR}
# Setup Git configuration
COMMIT_USER=$(git log --format='%an' ${TRAVIS_COMMIT}^\!)
COMMIT_EMAIL=$(git log --format='%ae' ${TRAVIS_COMMIT}^\!)
git config user.name "Geo Ninja"
git config user.email "qgisninja@gmail.com"
REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}


# Build the bottles
mkdir -p bottles

pushd bottles
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."
    brew bottle --verbose --json --root-url=https://osgeo4mac.s3.amazonaws.com/bottles \
      ${TRAVIS_REPO_SLUG}/${f}

#    temporary duplication of 10.2-Xcode-8.x-built bottles to 10.3 bottles
#    Do the bottle duplication per formula, so we can merge the changes
    for art in ${f}*.sierra.bottle.*; do
      new_name=${art/.sierra./.high_sierra.}
      cp -a ${art} ${new_name}
    done
    for json in ${f}*.high_sierra.bottle*.json; do
      sed -i '' s@sierra@high_sierra@g ${json}
    done

#    Do Merge bottles with the formula
#    Don't commit anything, we'll do that after updating all the formulae
    brew bottle --merge --write --no-commit ${f}*.json
  done
popd

# Now do the commit and push

git add -vA Formula/*.rb
git commit -m "Updated bottles for: ${CHANGED_FORMULAE}

Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
[ci skip]"

# Get the deploy key by using Travis's stored variables to decrypt deploy_key.enc
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in ./deploy_key.enc -out ./deploy_key -d
chmod 600 ./deploy_key
eval `ssh-agent -s`
ssh-add deploy_key

# Now that we're all set up, we can push.
git push ${SSH_REPO} $TRAVIS_BRANCH
