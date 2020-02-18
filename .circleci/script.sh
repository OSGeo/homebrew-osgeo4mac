#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - script.sh
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

ulimit -n 1024

if [ "$CIRCLE_BRANCH" != "master" ]; then
git checkout bottles

echo ${CHANGED_FORMULAE}

for f in ${CHANGED_FORMULAE};do
  deps=$(brew deps --include-build ${f})

  # fix error: Unable to import PyQt5.QtCore
  # build qscintilla2
  if [ "$(echo ${deps} | grep -c 'osgeo-pyqt')" != "0" ];then
    brew reinstall ${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/osgeo-pyqt
    brew unlink osgeo-pyqt && brew link osgeo-pyqt --force
    /usr/local/opt/python/bin/python3 -c "import PyQt5.QtCore"
  fi

  # fix error: 'libintl.h' file not found
  # build qgis with grass
  if [ "$(echo ${deps} | grep -c 'osgeo-grass')" != "0" ] || [ "${f}" == "osgeo-grass" ];then
    brew reinstall gettext
    brew unlink gettext && brew link --force gettext
  fi

  if [ "${f}" == "osgeo-grass" ];then
    brew unlink osgeo-liblas && brew link osgeo-liblas --force
  fi

  # Error: The `brew link` step did not complete successfully
  # The formula built, but is not symlinked into /usr/local
  # Could not symlink lib/pkgconfig/libopenjp2.pc
  # Target /usr/local/lib/pkgconfig/libopenjp2.pc
  # is a symlink belonging to openjpeg
  if [ "$(echo ${deps} | grep -c 'osgeo-insighttoolkit')" != "0" ] || [ "${f}" == "osgeo-insighttoolkit" ];then
    brew unlink openjpeg
  fi

  if [ "$(echo ${deps} | grep -c 'osgeo-insighttoolkit@4')" != "0" ] || [ "${f}" == "osgeo-insighttoolkit@4" ];then
    brew unlink openjpeg
  fi

  # fix test
  # initdb: could not create directory "/usr/local/var/postgresql": Operation not permitted
  if [ "${f}" == "osgeo-libpqxx" ];then
    initdb /usr/local/var/postgresql -E utf8 --locale=en_US.UTF-8
    # pg_ctl -D /usr/local/var/postgresql -l logfile start
    brew services start osgeo/osgeo4mac/osgeo-postgresql
    # system "psql", "-h", "localhost", "-d", "postgres"
    # createdb template1
  fi

  # mapnik - error high_sierra-build
  # Exiting... the following required dependencies were not found:
  #  - boost regex (more info see: https://github.com/mapnik/mapnik/wiki/Mapnik-Installation & http://www.boost.org)
  # Also, these OPTIONAL dependencies were not found:
  #  - boost program_options (more info see: https://github.com/mapnik/mapnik/wiki/Mapnik-Installation & http://www.boost.org)
  #  - boost_regex_icu (libboost_regex built with optional ICU unicode support is needed for unicode regex support in mapnik.)
  #  - gdal (GDAL C++ library | configured using gdal-config program | try setting GDAL_CONFIG SCons option | more info: https://github.com/mapnik/mapnik/wiki/GDAL)
  if [ "${f}" == "osgeo-mapnik" ];then
    brew unlink boost && brew link boost --force
  fi
  # if SVG2PNG=True
  # Error: Failed changing install name in /usr/local/Cellar/osgeo-mapnik/3.0.22_2/bin/svg2png
  # from /usr/local/opt/boost/lib/libboost_system.dylib
  # to @@HOMEBREW_PREFIX@@/opt/boost/lib/libboost_system.dylib
  # Error: Updated load commands do not fit in the header of
  # /usr/local/Cellar/osgeo-mapnik/3.0.22_2/bin/svg2png. /usr/local/Cellar/osgeo-mapnik/3.0.22_2/bin/svg2png
  # needs to be relinked, possibly with -headerpad or -headerpad_max_install_names

  # if [[ $(brew list --versions ${f}) ]]; then
  #   echo "Clearing previously installed/cached formula ${f}..."
  #   brew uninstall --force --ignore-dependencies ${f} || true
  # fi

  echo "Installing changed formula ${f}..."
  # Default installation flag set
  FLAGS="--build-bottle"

  brew install -v ${FLAGS} ${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${f}&
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
  brew test ${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${f}
done
fi
