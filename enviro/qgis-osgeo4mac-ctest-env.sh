export DYLD_LIBRARY_PATH=${QGIS_BUILD}/output/lib:${QGIS_BUILD}/PlugIns/qgis
export PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
export PYTHONHOME=${HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/2.7
export PYTHONPATH=${HOMEBREW_PREFIX}/lib/python2.7/site-packages
export PYQGIS_STARTUP=${HOMEBREW_PREFIX}/Library/Taps/osgeo/homebrew-osgeo4mac/enviro/python_startup.py
export GDAL_DRIVER_PATH=${HOMEBREW_PREFIX}/lib/gdalplugins

cd ${QGIS_BUILD}

echo "Homebrew:          $HOMEBREW_PREFIX"
echo "DYLD_LIBRARY_PATH: $DYLD_LIBRARY_PATH"
echo "PATH:              $PATH"
echo "PYTHONHOME:        $PYTHONHOME"
echo "PYTHONPATH:        $PYTHONPATH"
echo "PYQGIS_STARTUP:    $PYQGIS_STARTUP"
echo "GDAL_DRIVER_PATH:  $GDAL_DRIVER_PATH"
