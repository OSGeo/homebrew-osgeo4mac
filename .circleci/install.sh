#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - install.sh
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

rm /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sip.rb
rm /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/pyqt.rb
rm /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/qscintilla2.rb

brew tap osgeo/osgeo4mac
brew tap-pin osgeo/osgeo4mac

for f in ${CHANGED_FORMULAE};do
  echo "Installing dependencies for changed formula ${f}..."
  FLAGS="--only-dependencies --build-bottle"

  brew install ${FLAGS} ${TRAVIS_REPO_SLUG}/${f}&
  PID=$!
  # add progress to ensure Travis doesn't complain about no output
  while true; do
    sleep 30
    if jobs -rp | grep ${PID} >/dev/null; then
      echo "."
    else
      echo
      break
    fi
  done
done
