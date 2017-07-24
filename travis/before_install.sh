#!/usr/bin/env bash
###########################################################################
#    homebrew-qgisdev travis ci - before_install.sh
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

if [ -n "${DEBUG_TRAVIS}" ];then
  brew list --versions
fi

# Remove default gdal provided by travis (we will replace it with gdal2)
brew remove gdal || true

# Add taps
brew tap homebrew/science || true

brew update || brew update

for f in ${CHANGED_FORMULAE};do
  echo "Homebrew setup for changed formula ${f}..."
  deps=$(brew deps -1 --include-build ${f})
  echo "${f} dependencies: ${deps}"

  if [ "$(echo ${deps} | grep -c 'python')" != "0" ];then
    echo "Installing and configuring Homebrew Python"
    # Already installed, upgrade, if necessary
    brew outdated python || brew upgrade python

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(${HOMEBREW_PREFIX}/bin/python2 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")
    mkdir -p ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/opt/gdal2/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python dependencies"
      ${HOMEBREW_PREFIX}/bin/pip install numpy
    fi
    if [[ "${f}" =~ "qgis" ]];then
      echo "Installing QGIS Python dependencies for testing"
      ${HOMEBREW_PREFIX}/bin/pip install future mock nose2 numpy psycopg2 pyyaml
    fi
  fi

  if [ "$(echo ${deps} | grep -c 'python3')" != "0" ];then
    echo "Installing and configuring Homebrew Python3"
    brew install python3

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(${HOMEBREW_PREFIX}/bin/python3 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")
    mkdir -p ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/opt/gdal2/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python dependencies"
      ${HOMEBREW_PREFIX}/bin/pip3 install numpy
    fi
    if [[ "${f}" =~ "qgis" ]];then
      echo "Installing QGIS Python dependencies for testing"
      ${HOMEBREW_PREFIX}/bin/pip3 install future mock nose2 numpy psycopg2 pyyaml
    fi
  fi

done
