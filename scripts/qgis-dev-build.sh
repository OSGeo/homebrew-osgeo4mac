#!/bin/bash
###########################################################################
# Script for CMake build of QGIS when built off Homebrew dependencies
#                              -------------------
#        begin    : November 2016
#        copyright: (C) 2016 Larry Shaffer
#        email    : larrys at dakotacarto dot com
###########################################################################
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
###########################################################################

# exit on errors
set -e

usage(){
  echo "usage: <script> 'absolute path to build directory'"
  exit 1
}

if [ "$#" -ne 1 ]; then
  usage
fi

BUILD_DIR="$1"

if ! [[ "${BUILD_DIR}" = /* ]] || ! [ -d "${BUILD_DIR}" ]; then
  usage
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

source ${SCRIPT_DIR}/qgis-dev.env "${BUILD_DIR}"

checkcmake
checkqt4
checkpyqt4
checktxt2tags

echo "Building QGIS..."
cd $BUILD_DIR
time $CMAKE --build . --target all -- -j${CPUCORES}

# # stage/compile plugins so they are available when running from build directory
# echo "Staging plugins to QGIS build directory..."
# $CMAKE --build . --target staged-plugins-pyc

# write LSEnvironment entity to app's Info.plist
if [ -d "${BUILD_DIR}/output/bin/QGIS.app" ]; then
  # this differs from LSEnvironment in bundled app; see set-qgis-app-env.py
  echo "Setting QGIS.app environment variables..."
  $SCRIPT_DIR/qgis-set-app-env.py -p ${HOMEBREW_PREFIX} -b ${BUILD_DIR} "${BUILD_DIR}/output/bin/QGIS.app"
fi

exit 0
