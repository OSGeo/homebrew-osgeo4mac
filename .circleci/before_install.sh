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

for f in ${CHANGED_FORMULAE};do
  echo 'Setting up, before install'
  if [ -n "${DEBUG_CI}" ];then
    brew list --versions
  fi

  # Forcibly remove all versions of unneeded default formula provided by travis or pre-cached
  nix_f="
  gdal
  sip
  pyqt
  qscintilla2
  postgresql@10
  postgis
  "

  for nf in ${nix_f}; do
    brew uninstall --force --ignore-dependencies ${nf} || true
  done

  # brew update > /dev/null
  # brew update - slow
  # brew update-reset

  # fix: Permission Denied When Creating Directory or Writing a File
  # https://support.circleci.com/hc/en-us/articles/360003649774-Permission-Denied-When-Creating-Directory-or-Writing-a-File
  # chown -R $USER:$USER /Users/distiller
  chown -R $USER: /Users/distiller



  echo "Homebrew setup for changed formula ${f}..."
  deps=$(brew deps --include-build ${f})
  echo "${f} dependencies:"
  echo "${deps}"

  # Install XQuartz
  if [ "$(echo ${deps} | grep -c 'osgeo-grass')" != "0" ] || [ "$(echo ${deps} | grep -c 'osgeo-openscenegraph')" != "0" ];then
    echo "one of the dependencies requires XQuartz, installing..."
    brew cask install xquartz
  fi
  if [ "${f}" == "osgeo-grass" ] || [ "${f}" == "osgeo-openscenegraph" ];then
    echo "${f} require of XQuartz, installing..."
    brew cask install xquartz
  fi

  if [ "$(echo ${deps} | grep -c '[python@2|python2]')" != "0" ];then
    echo "Installing and configuring Homebrew Python 2"
    brew reinstall python@2

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(/usr/local/bin/python2 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
    if [ -n "${DEBUG_CI}" ];then
      echo $PY_VER
    fi
    mkdir -p ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages

    echo 'import site; site.addsitedir("/usr/local/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("/usr/local/opt/osgeo-gdal/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "osgeo-gdal" ]];then
      echo "Installing GDAL 2 Python 2 dependencies"
      /usr/local/bin/pip2 install numpy
    fi
  fi

  if [ "$(echo ${deps} | grep -c '[python|python3]')" != "0" ];then
    echo "Installing and configuring Homebrew Python 3"
    brew reinstall python

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(/usr/local/bin/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
    if [ -n "${DEBUG_CI}" ];then
      echo $PY_VER
    fi
    mkdir -p ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages

    echo 'import site; site.addsitedir("/usr/local/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("/usr/local/opt/osgeo-gdal/lib/python${PY_VER}/site-packages")' \
         >> ${CIRCLE_WORKING_DIRECTORY}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "osgeo-gdal" ]];then
      echo "Installing GDAL 2 Python 3 dependencies"
      /usr/local/bin/pip3 install numpy
    fi
  fi

  # Special handling of osgeo-grass, because it needs to be unlinked
  if [ "$(echo ${deps} | grep -c 'osgeo-grass')" != "0" ];then
    echo "Installing and unlinking grass7"
    # GDAL gets its numpy installed via pip, but grass also has a dependency, so we need to force it.
    brew install numpy || brew link --overwrite numpy
    brew install osgeo-grass
    brew unlink osgeo-grass
  fi
done
