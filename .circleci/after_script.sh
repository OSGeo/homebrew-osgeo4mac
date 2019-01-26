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

# Build the actual bottles
# In Travis, this used to be part of the deploy phase, but now it needs to run as part of the original build process, but only on master.
mkdir -p /tmp/bottles

pushd /tmp/bottles
  TAP_PATH=$(brew --repo $CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME)
  mkdir -p $TAP_PATH
  cp -a ./ $TAP_PATH/
  brew tap --repair
  RELEASE_TAG=$(echo "$CIRCLE_BRANCH" | sed -nE 's/(^[@a-z0-9\.\-]+-[0-9\._]+)#(macos-)?bottle$/\1/p')
  FORMULA=$(echo "$RELEASE_TAG" | sed -nE 's/(^[@a-z0-9\.\-]*)-[0-9\._]*$/\1/p')
  BOTTLE_ROOT=https://github.com/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases/download/$RELEASE_TAG
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."
    brew bottle --verbose --json --root-url=${BOTTLE_ROOT} osgeo/osgeo4mac/${f}
    # brew install --build-from-source --build-bottle $FORMULA
    # brew bottle --verbose --json --root-url=${BOTTLE_ROOT} $FORMULA

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
    # upload bottles to github releases
    brew tap tcnksm/ghr
    brew install ghr
    RELEASE_TAG=$(echo "$CIRCLE_BRANCH" | sed -nE 's/(^[@a-z0-9\.\-]+-[0-9\._]+)#(macos-)?bottle$/\1/p')
    ghr --username $CIRCLE_PROJECT_USERNAME -r $CIRCLE_PROJECT_REPONAME --token $GITHUB_TOKEN --replace "$RELEASE_TAG" /tmp/bottles
  done
popd
