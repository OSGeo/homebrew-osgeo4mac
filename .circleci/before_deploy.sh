#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - before_deploy.sh
#    ---------------------
#    Date                 : Dec 2019
#    Copyright            : (C) 2016 by Boundless Spatial, Inc.
#    Author               : Larry Shaffer - FJ Perini
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

if [ "$CIRCLE_BRANCH" == "bottles" ] && [ "$CHANGED_FORMULAE" != "" ]; then
  # Setup Git configuration
  COMMIT_USER=$(git log --format='%an' ${CIRCLE_SHA1}^\!)
  COMMIT_EMAIL=$(git log --format='%ae' ${CIRCLE_SHA1}^\!)
  git config user.name "geo-ninja"
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

  BUILT_BOTTLES=
  pushd /tmp/workspace/bottles/
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

  # Now do the commit and push
  echo "Commit and push..."
  git add -vA Formula/*.rb
  git commit -m "Updated bottles for: ${BUILT_BOTTLES}

  Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
  [ci skip]"

  # fix if there is a new commit in master
  echo "Pull rebase..."
  # git checkout $CIRCLE_BRANCH
  # git merge master

  # git pull <remote> <branch>
  # git branch --set-upstream-to=origin/<branch> bottles

  git checkout bottles
  git rebase bottles
  git checkout bottles
  git merge bottles
  
  git pull ${SSH_REPO} $CIRCLE_BRANCH
  git branch --set-upstream-to=origin/bottles bottles

  git pull --rebase

  # Now that we're all set up, we can push.
  git push ${SSH_REPO} $CIRCLE_BRANCH

  # echo "Upload to Bintray..."

  cd /tmp/workspace/bottles/

  # files=$(echo *.tar.gz | tr ' ' ',')
  # curl -X PUT -T "{$files}" -u ${BINTRAY_USER}:${BINTRAY_API} -H "X-Bintray-Publish: 1" https://api.bintray.com/content/homebrew-osgeo/osgeo-bottles/bottles/0.1/

  echo "Upload Bottles..."
    # use ssh
    # ssh-add -l
    # echo -e "\nIdentityFile ~/.ssh/id_rsa" >> ~/.ssh/config
    # cat ~/.ssh/config
    # ls ~/.ssh
    # brew install https://raw.githubusercontent.com/hudochenkov/homebrew-sshpass/master/sshpass.rb
    # sshpass -e scp -P 50023 -o stricthostkeychecking=no -r ./*.tar.gz fjperini@bottle.download.osgeo.org:/osgeo/bottle
    scp -P 50023 -o stricthostkeychecking=no -r ./*.tar.gz fjperini@bottle.download.osgeo.org:/osgeo/bottle
fi
