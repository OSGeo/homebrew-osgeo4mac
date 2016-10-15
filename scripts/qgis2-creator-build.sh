#!/bin/bash

BUILD_DIR="$1"

if ! [[ "$BUILD_DIR" = /* ]] || ! [ -d "$BUILD_DIR" ]; then
  echo "usage: <script> 'absolute path to QGIS CMake build directory'"
  exit 1
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

# use maximum number of available cores
CPUCORES=$(/usr/sbin/sysctl -n hw.ncpu)

# if HOMEBREW_PREFIX undefined in env, then set to standard prefix
if [ -z "$HOMEBREW_PREFIX" ]; then
  HOMEBREW_PREFIX='/usr/local'
fi

# set up environment
export PATH=${HOMEBREW_PREFIX}/opt/gdal2/bin:${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}
export PYTHONPATH=${HOMEBREW_PREFIX}/lib/qt-4/python2.7/site-packages:${HOMEBREW_PREFIX}/opt/gdal2/lib/python2.7/site-packages:${HOMEBREW_PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}

echo "PATH set to: ${PATH}"
echo "PYTHONPATH set to: ${PYTHONPATH}"
echo "BUILD_DIR set to: ${BUILD_DIR}"

echo "Building QGIS..."
make -j ${CPUCORES}
if [ $? -gt 0 ]; then
    echo -e "\nERROR building QGIS"
    exit 1
fi

# # stage/compile plugins so they are available when running from build directory
# echo "Staging plugins to QGIS build directory..."
# make -j ${CPUCORES} staged-plugins-pyc
# if [ $? -gt 0 ]; then
#     echo -e "\nERROR staging plugins to QGIS build directory"
#     exit 1
# fi

# write LSEnvironment entity to app's Info.plist
if [ -d "${BUILD_DIR}/output/bin/QGIS.app" ]; then
  # this differs from LSEnvironment in bundled app; see set-qgis-app-env.py
  echo "Setting QGIS.app environment variables..."
  ${SCRIPT_DIR}/qgis-set-app-env.py -p ${HOMEBREW_PREFIX} -b ${BUILD_DIR} "${BUILD_DIR}/output/bin/QGIS.app"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting QGIS.app environment variables"
      exit 1
  fi
fi

if [ -d "${BUILD_DIR}/output/bin/QGIS Browser.app" ]; then
  echo "Setting QGIS Browser.app environment variables..."
  ${SCRIPT_DIR}/qgis-set-app-env.py -p ${HOMEBREW_PREFIX} -b ${BUILD_DIR} "${BUILD_DIR}/output/bin/QGIS Browser.app"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting QGIS Browser.app environment variables"
      exit 1
  fi
fi

exit 0
