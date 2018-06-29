#!/bin/bash
###########################################################################
# Script for CMake testing build of QGIS when built off Homebrew dependencies
#                              -------------------
#        begin    : March 2017
#        copyright: (C) 2017 Larry Shaffer
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
  echo "usage: <script> 'absolute path to build directory' [\"ctest options\"]"
}

BUILD_DIR="$1"

if ! [[ "${BUILD_DIR}" = /* ]] || ! [ -d "${BUILD_DIR}" ]; then
  usage
  exit 1
fi

CTEST_OPTS=
if [ "$#" -gt 1 ] && [ -n "$2" ]; then
  CTEST_OPTS=$2
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

source ${SCRIPT_DIR}/qgis-dev.env "${BUILD_DIR}"

checkctest

echo "Testing QGIS..."
cd $BUILD_DIR
time $CTEST $CTEST_OPTS

exit 0
