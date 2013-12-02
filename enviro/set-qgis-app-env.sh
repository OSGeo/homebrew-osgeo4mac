#!/bin/bash

# usage: <script> "path to .app bundle"

# convert to absolute path (needed by 'defaults' command)
CMD="import os, sys; print os.path.realpath(\"$1\")"
# echo $CMD

APP=$(/usr/bin/python -c "$CMD" )

if ! [[ "$APP" = /* ]]; then

  echo "App path not absolute:"
  echo "$APP"
  exit 1
fi

DOMAIN="$APP/Contents/Info"
PLIST="$DOMAIN.plist"

if ! [ -f "$PLIST" ]; then

  echo "Info.plist not found at:"
  echo "$PLIST"
  exit 1

fi

# first delete any LSEnvironment setting, ignoring errors
# CAUTION!: this may not be what you want, if the .app already has LSEnvironment settings
defaults delete "$DOMAIN" "LSEnvironment" 2> /dev/null

defaults write "$PLIST" "LSEnvironment" '{
  "DYLD_FRAMEWORK_PATH" = "/usr/local/Frameworks:/System/Library/Frameworks";
  "DYLD_VERSIONED_LIBRARY_PATH" = "/usr/local/opt/sqlite/lib:/usr/local/opt/libxml2/lib:/usr/local/lib";
  "PATH" = "/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin";
  "GDAL_DRIVER_PATH" = "/usr/local/lib/gdalplugins";
  "PYTHONHOME" = "/usr/local/Frameworks/Python.framework/Versions/2.7";
  "PYTHONPATH" = "/usr/local/lib/python2.7/site-packages";
  "PYQGIS_STARTUP" = "/usr/local/Library/Taps/dakcarto-osgeo4mac/enviro/python_startup.py";
  "OSG_LIBRARY_PATH" = "/usr/local/lib/osgPlugins-3.2.0";
}'

# leave the plist readable; convert from binary to XML format
plutil -convert xml1 -- "$PLIST"

# update modification date on app bundle, or changes won't take effect
touch "$APP"

exit 0
