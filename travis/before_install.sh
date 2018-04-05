#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac travis ci - before_install.sh
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

# Forcibly remove all versions of unneeded default formula provided by travis or pre-cached
nix_f="
gdal
"

for f in ${nix_f}; do
  brew uninstall --force --ignore-dependencies ${f} || true
done

# Add taps
brew tap homebrew/science || true
#brew tap caskroom/cask || true

# Keeps gcc from being linked
brew cask uninstall oclint || true

brew update || brew update

# Set up ccache (doesn't work with `brew install <formula>`)
#brew install ccache
#export PATH="/usr/local/opt/ccache/libexec:$PATH"
#
#ccache -M 500M
#ccache -z

for f in ${CHANGED_FORMULAE};do
  echo "Homebrew setup for changed formula ${f}..."
  deps=$(brew deps -1 --include-build ${f})
  echo "${f} dependencies: ${deps}"

  # Upgrade Python3 to the latest version, before installing Python2. Per the discussion here
  # https://discourse.brew.sh/t/brew-install-python3-fails/1756/3
  if [ "$(echo ${deps} | grep -c 'python3')" != "0" ];then
    echo "Installing and configuring Homebrew Python3"
    brew outdated python || brew upgrade python

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(${HOMEBREW_PREFIX}/bin/python3 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")
    if [ -n "${DEBUG_TRAVIS}" ];then
      echo $PY_VER
    fi
    mkdir -p ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/opt/gdal2/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python3 dependencies"
      ${HOMEBREW_PREFIX}/bin/pip3 install numpy
    fi
    if [[ "${f}" =~ "qgis" ]];then
      echo "Installing QGIS Python3 dependencies for testing"
      ${HOMEBREW_PREFIX}/bin/pip3 install future mock nose2 numpy psycopg2 pyyaml
    fi
  fi

  if [ "$(echo ${deps} | grep -c 'python')" != "0" ];then
    echo "Installing and configuring Homebrew Python2"
    # If we just upgraded to Python3, install python2, otherwise, update it
    if [ "$(echo ${deps} | grep -c 'python3')" != "0" ];then
      brew install python@2
    else
      brew outdated python@2 || brew upgrade python@2
    fi

    # Set up Python .pth files
    # get python short version (major.minor)
    PY_VER=$(${HOMEBREW_PREFIX}/bin/python2 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")
    if [ -n "${DEBUG_TRAVIS}" ];then
      echo $PY_VER
    fi
    mkdir -p ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/opt/gdal2/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "gdal2" ]];then
      echo "Installing GDAL 2 Python2 dependencies"
      ${HOMEBREW_PREFIX}/bin/pip2 install numpy
    fi
    if [[ "${f}" =~ "qgis" ]];then
      echo "Installing QGIS Python2 dependencies for testing"
      ${HOMEBREW_PREFIX}/bin/pip2 install future mock nose2 numpy psycopg2 pyyaml
    fi
  fi
done

