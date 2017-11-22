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
mkdir -p bottles

pushd bottles
  for f in ${CHANGED_FORMULAE};do
    echo "Bottling changed formula ${f}..."
    brew bottle --verbose --json --root-url=https://osgeo4mac.s3.amazonaws.com/bottles \
      ${TRAVIS_REPO_SLUG}/${f}
  done

  # temporary duplication of 10.2-Xcode-8.x-built bottles to 10.3 bottles
  for art in *.sierra.bottle.*; do
    new_name=${art/.sierra./.high_sierra.}
    cp -a ${art} ${new_name}
  done
  for json in *.high_sierra.bottle*.json; do
    sed -i '' s@sierra@high_sierra@g ${json}
  done
popd
