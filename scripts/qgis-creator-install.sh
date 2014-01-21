#!/bin/bash

OUTPUT_DIR="$1"

if ! [[ "$OUTPUT_DIR" = /* ]] || ! [ -d "$OUTPUT_DIR" ]; then
  echo "usage: <script> 'absolute path to QGIS.app's install directory'"
  exit 1
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

# use maximum number of available cores
CPUCORES=$(/usr/sbin/sysctl -n hw.ncpu)

QGIS="$OUTPUT_DIR/QGIS.app"

# if HOMEBREW_PREFIX undefined in env, then set to standard prefix
if [ -z "$HOMEBREW_PREFIX" ]; then
  HOMEBREW_PREFIX='/usr/local'
fi

# ensure we can delete previous, then delete it QGIS.app
if [ -d "${QGIS}" ]; then
  /bin/chmod -R u+w "${QGIS}"
  /bin/rm -fdR "${QGIS}"
fi

echo "Installing QGIS..."
make -j ${CPUCORES} install
if [ $? -gt 0 ]; then
    echo -e "\nERROR installing QGIS"
    exit 1
fi

if [ -d "${QGIS}" ]; then

  # ensure we can write to QGIS.app bundle components
  # NOTE: Homebrew's binaries are built as non-writable
  /bin/chmod -R u+w "${QGIS}"

  # write LSEnvironment entity to app's Info.plist
  # this differs from LSEnvironment in app run from build directory; see set-qgis-app-env.py
  echo "Setting QGIS.app environment variables..."
  ${SCRIPT_DIR}/set-qgis-app-env.py -p ${HOMEBREW_PREFIX} "${QGIS}"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting installed QGIS.app environment variables"
      exit 1
  fi

  echo "Setting QGIS Browser.app environment variables..."
  ${SCRIPT_DIR}/set-qgis-app-env.py -p ${HOMEBREW_PREFIX} "${QGIS}/Contents/MacOS/bin/QGIS Browser.app"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting installed QGIS Browser.app environment variables"
      exit 1
  fi

fi

exit 0
