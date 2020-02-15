#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac circle ci - script.sh
#    ---------------------
#    Date                 : Dec 2019
#    Copyright            : (C) 2016 by Boundless Spatial, Inc.
#    Author               : Larry Shaffer -  FJ Perini
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

if [ "$CIRCLE_BRANCH" != "master" ]; then
ulimit -c unlimited
           ulimit -n 2048
           export CHANGED_FORMULAE=$(.circleci/changed_formulas.sh)
           if [ "$CHANGED_FORMULAE" == "" ]; then
             echo "Skipping CI, no changed formulae found";
             exit 0;
           else
             echo "Changed formulae are ${CHANGED_FORMULAE}";
           fi
           export HOMEBREW_REPOSITORY=$(brew --repo)
           git -C "${HOMEBREW_REPOSITORY}" fetch
           git -C "${HOMEBREW_REPOSITORY}" reset --hard origin/master
           mkdir -p "${HOMEBREW_REPOSITORY}/Library/Taps/${CIRCLE_PROJECT_USERNAME}"
           echo "Linking ${CIRCLE_WORKING_DIRECTORY}" to "${HOMEBREW_REPOSITORY}/Library/Taps/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
           ln -s "${HOME}/project" "${HOMEBREW_REPOSITORY}/Library/Taps/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
           echo "export CHANGED_FORMULAE=${CHANGED_FORMULAE}" >> $BASH_ENV
           echo "export HOMEBREW_REPOSITORY=$HOMEBREW_REPOSITORY" >> $BASH_ENV
           echo 'export HOMEBREW_DEVELOPER=1' >> $BASH_ENV
           echo 'export HOMEBREW_NO_AUTO_UPDATE=1' >> $BASH_ENV
           echo 'export HOMEBREW_PREFIX=/usr/local' >> $BASH_ENV
           echo 'export CIRCLE_REPOSITORY_URL=https://github.com/OSGeo/homebrew-osgeo4mac' >> $BASH_ENV
           echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)' >> $BASH_ENV
fi
