#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac travis ci - script.sh
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

for f in ${CHANGED_FORMULAE};do
  deps=$(brew deps --include-build ${f})

  # fix error: Unable to import PyQt5.QtCore
  # build qscintilla2
  if [ "$(echo ${deps} | grep -c 'osgeo-pyqt')" != "0" ];then
    brew reinstall ${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/osgeo-pyqt
    brew unlink osgeo-pyqt && brew link osgeo-pyqt --force
    /usr/local/bin/pip2 install enum34
    /usr/local/bin/python2 -c "import PyQt5.QtCore"
    /usr/local/bin/python3 -c "import PyQt5.QtCore"
  fi

  # fix error: 'libintl.h' file not found
  # build qgis with grass
  if [ "$(echo ${deps} | grep -c 'osgeo-grass')" != "0" ];then
    brew reinstall gettext
    brew unlink gettext && brew link --force gettext
  fi

  # if [[ $(brew list --versions ${f}) ]]; then
  #   echo "Clearing previously installed/cached formula ${f}..."
  #   brew uninstall --force --ignore-dependencies ${f} || true
  # fi

  echo "Installing changed formula ${f}..."
  # Default installation flag set
  FLAGS="--build-bottle"

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

  echo "Testing changed formula ${f}..."
  # does running postinstall mess up the bottle?
  # (mentioned that it is skipped if installing with --build-bottle)
  # brew postinstall ${f}
  brew test ${TRAVIS_REPO_SLUG}/${f}
done
