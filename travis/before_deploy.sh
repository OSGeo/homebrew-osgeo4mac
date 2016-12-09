#!/usr/bin/env bash
###########################################################################
#    homebrew-qgisdev travis ci - before_deploy.sh
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
    brew bottle --verbose --root-url=http://qgis.dakotacarto.com/bottles \
      ${GH_USER}/${GH_REPO}/${f}
  done
popd
