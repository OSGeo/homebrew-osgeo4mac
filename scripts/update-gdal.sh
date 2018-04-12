#!/usr/bin/env bash

VERSION=$1

GDAL_URL=http://download.osgeo.org/gdal/${VERSION}/gdal-${VERSION}.tar.gz
GDAL_GRASS_URL=http://download.osgeo.org/gdal/${VERSION}/gdal-grass-${VERSION}.tar.gz
GDAL_AUTOTEST_URL=http://download.osgeo.org/gdal/${VERSION}/gdalautotest-${VERSION}.tar.gz

wget $GDAL_URL
wget $GDAL_GRASS_URL
wget $GDAL_AUTOTEST_URL

GDAL_SHA=$(shasum -a 256 gdal-${VERSION}.tar.gz | cut -f 1 -d " ")
GDAL_GRASS_SHA=$(shasum -a 256 gdal-grass-${VERSION}.tar.gz | cut -f 1 -d " ")
GDAL_AUTOTEST_SHA=$(shasum -a 256 gdalautotest-${VERSION}.tar.gz | cut -f 1 -d " ")

find Formula -type f -iname "gdal2*" -exec perl -i -0pe "s@url \"http://download.osgeo.org/gdal/[0-9.]+/gdal-[0-9.]+.tar.gz\"(\n\s*sha256 )\"\w+\"@url \"${GDAL_URL}\"\1\"${GDAL_SHA}\"@igs" {} \;
find Formula -type f -iname "gdal2*" -exec perl -i -0pe "s@url \"http://download.osgeo.org/gdal/[0-9.]+/gdal-grass-[0-9.]+.tar.gz\"(\n\s*sha256 )\"\w+\"@url \"${GDAL_GRASS_URL}\"\1\"${GDAL_GRASS_SHA}\"@igs" {} \;
find Formula -type f -iname "gdal2*" -exec perl -i -0pe "s@url \"http://download.osgeo.org/gdal/[0-9.]+/gdalautotest-[0-9.]+.tar.gz\"(\n\s*sha256 )\"\w+\"@url \"${GDAL_AUTOTEST_URL}\"\1\"${GDAL_AUTOTEST_SHA}\"@igs" {} \;

rm gdal-${VERSION}.tar.gz
rm gdal-grass-${VERSION}.tar.gz
rm gdalautotest-${VERSION}.tar.gz
