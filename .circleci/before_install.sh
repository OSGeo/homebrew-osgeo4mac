#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - before_install.sh
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

set -o errexit
set -o xtrace

if [ "$CIRCLE_BRANCH" != "master" ] && [ "$CHANGED_FORMULAE" != "" ]; then
for f in ${CHANGED_FORMULAE};do

  echo 'Setting up, before install'
  if [ -n "${DEBUG_CI}" ];then
    brew list --versions
  fi

  # Forcibly remove all versions of unneeded default formula provided by travis or pre-cached
  nix_f="
  gdal
  postgis
  "

  for f in ${nix_f}; do
    brew uninstall --force --ignore-dependencies ${f} || true
  done

  brew update > /dev/null

  # Install XQuartz
  brew cask install xquartz

  echo "Homebrew setup for changed formula ${f}..."
  deps=$(brew deps --include-build ${f})
  echo "${f} dependencies:"
  echo "${deps}"

  if [ "$(echo ${deps} | grep -c '[python@2|python2]')" != "0" ];then
    echo "Installing and configuring Homebrew Python 2"
    brew outdated python@2 || brew upgrade python@2

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(/usr/local/bin/python2 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
    if [ -n "${DEBUG_CI}" ];then
      echo $PY_VER
    fi
    mkdir -p ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages

    echo 'import site; site.addsitedir("/usr/local/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("/usr/local/opt/gdal2/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python 2 dependencies"
      /usr/local/bin/pip2 install numpy
    fi
  fi

  if [ "$(echo ${deps} | grep -c '[python|python3]')" != "0" ];then
    echo "Installing and configuring Homebrew Python 3"
    brew outdated python || brew upgrade python

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(/usr/local/bin/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
    if [ -n "${DEBUG_CI}" ];then
      echo $PY_VER
    fi
    mkdir -p ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages

    echo 'import site; site.addsitedir("/usr/local/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("/usr/local/opt/gdal2/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python 3 dependencies"
      /usr/local/bin/pip3 install numpy
    fi
  fi

  # Special handling of grass7, because it needs to be unlinked
  if [ "$(echo ${deps} | grep -c 'grass7')" != "0" ];then
    echo "Installing and unlinking grass7"
    # GDAL gets its numpy installed via pip, but grass also has a dependency, so we need to force it.
    brew install numpy || brew link --overwrite numpy
    brew install grass7
    brew unlink grass7
  fi

done
fi
