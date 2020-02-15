#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - after_script.sh
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

# OS X version
# sw_vers -productVersion
# sw_vers -productVersion | cut -d '.' -f 1,2
# MAJOR_MAC_VERSION=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')
# system_profiler SPSoftwareDataType

# Build the actual bottles
# In Travis, this used to be part of the deploy phase, but now it needs
# to run as part of the original build process, but only on master.
mkdir /tmp/bottles
if [ "$CIRCLE_BRANCH" != "master" ]; then
pushd /tmp/bottles
  # BOTTLE_ROOT=https://dl.bintray.com/homebrew-osgeo/osgeo-bottles
  BOTTLE_ROOT=https://bottle.download.osgeo.org
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."
    brew bottle --verbose --json --root-url=${BOTTLE_ROOT} osgeo/osgeo4mac/${f}

    # for art in ${f}*.sierra.bottle.*; do
        # Remove double dashes introduced by the latest changes to Homebrew bottling.
        # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
        # Move the sierra bottle and json file
        # mv ${art} ${art/--/-}
    # done

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

    # temporary duplication
    # Do the bottle duplication per formula, so we can merge the changes
    for art in ${f}*.high_sierra.bottle.*; do
      new_name=${art/.high_sierra./.catalina.}
      # Remove double dashes introduced by the latest changes to Homebrew bottling.
      # This may need to be reverted later, but this at least normalizes the bottle names with what's in the json files.
      cp -a ${art} ${new_name/--/-}
      # Move the high_sierra bottle and json file
      mv ${art} ${art/--/-}
    done
    for json in ${f}*.catalina.bottle*.json; do
      sed -i '' s@high_sierra@catalina@g ${json}
    done
  done
  ls
popd
fi
