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

pwd
ls

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

    # echo "Updating changed formula ${f} with new bottles..."

    # Do Merge bottles with the formula
    # Don't commit anything, we'll do that after updating all the formulae
    # Catch the eror and store it to a variable
    # if result=$(brew bottle --merge --write --no-commit ${f}*.json 2>&1); then
    #   BUILT_BOTTLES="$BUILT_BOTTLES ${f}"
    # else
    #  # If there's an error, remove the json and bottle files, we don't want them anymore.
    #  echo "Unable to bottle ${f}"
    #  echo $result
    #  rm ${f}*.json
    #  rm ${f}*.tar.gz
    # fi
  done
  ls
popd

# cd ${HOMEBREW_REPOSITORY}/Library/Taps/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}
#
# # Now do the commit and push
#
# git add -vA Formula/*.rb
# git commit -m "Updated bottles for: ${BUILT_BOTTLES}
#
# Committed for ${COMMIT_USER}<${COMMIT_EMAIL}>
# [ci skip]"
