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

# ccache -s

for f in ${CHANGED_FORMULAE};do

  # use ggprep instead of gprep
  brew install grep
  find ${HOMEBREW_REPOSITORY}/Cellar/${f} -name "${f}.rb" >> version.txt
  RELEASE_TAG_1=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" version.txt | head -n 1)
  RELEASE_TAG_2=$(ggrep -Po "(\d+\.)+(\d+\.)+\d" ${HOMEBREW_REPOSITORY}/Library/Taps/${TRAVIS_REPO_SLUG}/Formula/${f}.rb | head -n 1)
  # check RELEASE_TAG necessary to publish the bottles.
  echo "Release Tag: ${RELEASE_TAG_1}"
  echo "Release Tag: ${RELEASE_TAG_2}"

done
