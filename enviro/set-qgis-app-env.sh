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

# Starting from within homebrew tapped directory
ENVIRO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

BREW_TAP=$(dirname $ENVIRO_DIR)
if ! [ -d "$BREW_TAP" ]; then
  echo "Homebrew tap not found: $BREW_TAP"
  exit 1
fi

BREW_PREFIX=$(dirname $(dirname $(dirname $BREW_TAP ) ) )
if ! [ -d "$BREW_PREFIX" ]; then
  echo "Homebrew prefix not found: $BREW_PREFIX"
  exit 1
fi

# echo "Homebrew prefix: $BREW_PREFIX"
# echo "Homebrew tap is: $BREW_TAP"
# echo "osgeo4mac enviro: $ENVIRO_DIR"

# first delete any LSEnvironment setting, ignoring errors
# CAUTION!: this may not be what you want, if the .app already has LSEnvironment settings
defaults delete "$DOMAIN" "LSEnvironment" 2> /dev/null

defaults write "$PLIST" "LSEnvironment" "{
  'DYLD_FRAMEWORK_PATH' = '$BREW_PREFIX/Frameworks:/System/Library/Frameworks';
  'DYLD_VERSIONED_LIBRARY_PATH' = '$BREW_PREFIX/opt/sqlite/lib:$BREW_PREFIX/opt/libxml2/lib:$BREW_PREFIX/lib';
  'PATH' = '$BREW_PREFIX/bin:$BREW_PREFIX/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin';
  'GDAL_DRIVER_PATH' = '$BREW_PREFIX/lib/gdalplugins';
  'PYTHONHOME' = '$BREW_PREFIX/Frameworks/Python.framework/Versions/2.7';
  'PYTHONPATH' = '$BREW_PREFIX/lib/python2.7/site-packages';
  'PYQGIS_STARTUP' = '$BREW_PREFIX/Library/Taps/dakcarto-osgeo4mac/enviro/python_startup.py';
  'OSG_LIBRARY_PATH' = '$BREW_PREFIX/lib/osgPlugins-3.2.0';
}"

# leave the plist readable; convert from binary to XML format
plutil -convert xml1 -- "$PLIST"

# update modification date on app bundle, or changes won't take effect
touch "$APP"

exit 0
