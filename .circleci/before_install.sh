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

if [ "$CIRCLE_BRANCH" != "master" ]; then
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
  # rm -rf /Users/distiller/.viminf*
  # chown -R $USER: /Users/distiller

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

  if [ "$(echo ${deps} | grep -c '[python|python]')" != "0" ];then
    echo "Installing and configuring Homebrew Python 3"
    brew reinstall python

    echo "Link Python 3"
    # which python3
    brew unlink python && brew link --overwrite --force python

    # ls -l /usr/local/bin/python*
    # rm /usr/local/bin/python*
    # rm /usr/local/bin/pip*
    # rm -Rf /Library/Frameworks/Python.framework/Versions/*
    # export PATH=/usr/local/bin:/usr/local/sbin:$PATH
    # export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    # /usr/local/bin/python -V
    # /usr/local/bin/pip -V
    # cd /usr/local/bin
    # ln -s python3 python
    # ln -s pip3 pip


    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(/usr/local/opt/python/bin/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))')
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
      /usr/local/opt/python/bin/pip3 install numpy
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

  if [ "${f}" == "osgeo-vtk" ] || [ "${f}" == "osgeo-insighttoolkit" ] || [ "${f}" == "osgeo-insighttoolkit@4" ] || [ "${f}" == "osgeo-pcl" ] || [ "${f}" == "osgeo-pdal" ] || [ "${f}" == "osgeo-ossim" ] || [ "${f}" == "osgeo-orfeo" ];then
    echo "Installing jpeg-turbo"
    # osgeo-vtk: Java 1.8 is required to install this formula.
    # Install AdoptOpenJDK 8 with Homebrew Cask:
    # brew cask install homebrew/cask-versions/adoptopenjdk8
    brew install jpeg-turbo
    brew unlink jpeg-turbo && brew link --force jpeg-turbo
  fi
done
fi
