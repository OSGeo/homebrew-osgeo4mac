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

ls ./

# Setup Git configuration
COMMIT_USER=$(git log --format='%an' ${TRAVIS_COMMIT}^\!)
COMMIT_EMAIL=$(git log --format='%ae' ${TRAVIS_COMMIT}^\!)
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
branch_ref=$(git rev-parse "$TRAVIS_BRANCH")
if [[ $? -ne 0 || ! $branch_ref ]]; then
    err "failed to get $TRAVIS_BRANCH reference"
    return 1
fi
if [[ $head_ref != $branch_ref ]]; then
    msg "HEAD ref ($head_ref) does not match $TRAVIS_BRANCH ref ($branch_ref)"
    err "someone may have pushed new commits before this build cloned the repo"
    return 1
fi
if ! git checkout "$TRAVIS_BRANCH"; then
    err "failed to checkout $TRAVIS_BRANCH"
    return 1
fi


# Build the bottles
BUILT_BOTTLES=
mkdir -p bottles

pushd bottles
  # S3 bucket isn't currently working for the Travis pro repo, so we're switching to Bintray, for now.
  # BOTTLE_ROOT=https://osgeo4mac.s3.amazonaws.com/bottles
  # BOTTLE_ROOT=https://dl.bintray.com/homebrew-osgeo/osgeo-bottles
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."

    # use ggprep instead of gprep
    brew install grep
    # find ${HOMEBREW_PREFIX}/Cellar/${f} -name "${f}.rb" >> version.txt
    # RELEASE_TAG=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" version.txt | head -n 1)
    RELEASE_TAG=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" ${HOMEBREW_REPOSITORY}/Library/Taps/${TRAVIS_REPO_SLUG}/Formula/${f}.rb | head -n 1)
    echo "Release Tag: ${RELEASE_TAG}"

    BOTTLE_ROOT_URL=https://github.com/${TRAVIS_REPO_SLUG}/releases/download/${RELEASE_TAG}
    echo "The bottles will be uploaded to: ${BOTTLE_ROOT_URL}"

    brew bottle --verbose --json --root-url=${BOTTLE_ROOT} ${TRAVIS_REPO_SLUG}/${f}

    # temporary duplication of 10.2-Xcode-8.x-built bottles to 10.3 bottles
    # Do the bottle duplication per formula, so we can merge the changes
    for art in ${f}*.sierra.bottle.*; do
      new_name=${art/.sierra./.high_sierra.}
      # Remove double dashes introduced by the latest changes to Homebrew bottling.
      # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
      cp -a ${art} ${new_name/--/-}
      # Move the sierra bottle and json file
      mv ${art} ${art/--/-}
    done
    for json in ${f}*.high_sierra.bottle*.json; do
      sed -i '' s@sierra@high_sierra@g ${json}
    done

    # temporary duplication of 10.2-Xcode-8.x-built bottles to 10.4 bottles
    # Do the bottle duplication per formula, so we can merge the changes
    for art in ${f}*.sierra.bottle.*; do
      new_name=${art/.sierra./.mojave.}
      # Remove double dashes introduced by the latest changes to Homebrew bottling.
      # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
      cp -a ${art} ${new_name/--/-}
      # Move the sierra bottle and json file
      mv ${art} ${art/--/-}
    done
    for json in ${f}*.mojave.bottle*.json; do
      sed -i '' s@sierra@mojave@g ${json}
    done

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

    echo "Upload bottles to GitHub releases"

    # we could use the script upload_release.sh
    # in: travis.yml > before_deploy
    # - chmod +x ./travis/upload_release.sh
    # - ./travis/upload_release.sh

    # command-line tool to use with GitHub
    brew install hub

    ls ./

    # delete old release tag
    echo "Release Tag ${RELEASE_TAG} will be eliminated if existing"
    hub release delete "${RELEASE_TAG}"

    # tag_name="v${1}"

    asset_dir="."
    assets=()
    for b in "$asset_dir"/*; do [ -f "${b}" ] && assets+=(-a "${b}"); done

    # upload files
    hub release create "${assets[@]}" -m "Release ${RELEASE_TAG}" "${RELEASE_TAG}"

  done
popd

# Now do the commit and push

git add -vA Formula/*.rb
git commit -m "Updated bottles for: ${BUILT_BOTTLES}

Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
[ci skip]"

# Now that we're all set up, we can push.
git push ${SSH_REPO} $TRAVIS_BRANCH
