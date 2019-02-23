#!/usr/bin/env bash
###########################################################################
#    homebrew-osgeo4mac travis ci - before_cache.sh
#    ---------------------
#    Date                 : Aug 2017
#    Copyright            : (C) 2017 by Boundless Spatial, Inc.
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

rm -Rf $HOME/Library/Caches/Homebrew/*

# Remove unneeded formula for cache, e.g. occasional build-only packages
nix_f="
gcc
"

for f in ${nix_f}; do
  echo "Uninstalling formula ${f}..."
  brew uninstall --force --ignore-dependencies ${f} || true
done

# Remove large or unnecessary formulae, so they are not cached
un_f="
gdal2-
gdal1-
grass
mapserver
marble
monteverdi
pdfium
qgis
qt5
orfeo
saga-gis
taudem
"

bl=" $(brew list)"
# echo -n ${bl}
non_dep_f=''
for f in ${un_f};do
  non_dep_f+="$(echo -n ${bl} | egrep -o " ${f}\S*") "
done

for f in ${non_dep_f};do
  echo "Uninstalling non-dependency formula ${f}..."
  brew uninstall --force --ignore-dependencies ${f} || true
done

brew cleanup

# Let's see what's actually being cached
brew list --versions
