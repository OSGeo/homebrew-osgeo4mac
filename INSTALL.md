**QGIS 3.2 Bonn on macOS with Homebrew**

![QGIS](https://raw.githubusercontent.com/fjperini/homebrew-osgeo4mac/matplotlib-fix%2Bpython/screenshot.png "QGIS")

`$ brew tap osgeo/osgeo4mac`

Or install via URL (which will not receive updates):

`brew install https://raw.githubusercontent.com/osgeo/homebrew-osgeo4mac/master/Formula/qgis3.rb`

Another solution is to copy all the content directly to: `../Taps/osgeo/homebrew-osgeo4mac`

`$ cd /usr/local/Homebrew/Library/Taps/osgeo/homebrew-osgeo4mac`

`$ git checkout -b matplotlib-fix+python`

`$ brew edit qgis3-dev`

Fix for matplotlib and python. Change to:

```
url "https://github.com/qgis/QGIS.git", :branch => "release-3_2"
version “3.2.0"
```

```
depends_on “python"`
```

```
# depends_on "homebrew/science/matplotlib" # deprecated
depends_on "brewsci/bio/matplotlib"
```

`$ git add Formula/qgis3.rb`

`$ git commit -m "fix for matplotlib and python”`

For, ImportError: No module named site 

`$ brew install pyqt`

`$ brew install bison`

```
> $ python --version
Python 3.6.5
```

```
> $ python3 --version
Python 3.6.5
```

```
> $ python2 --version
Python 2.7.15
```

Modify the file `/usr/local/bin/pyrcc5` and change `pythonw2.7` to `python3`: 

```
#!/bin/sh
exec python3 -m PyQt5.pyrcc_main ${1+"$@"}
```

Build 

`$ brew install proj` # --build-from-source

Proj v5.1.0 # With Proj v4: Library not loaded: libproj.13.dylib

`$ brew install libspatialite` # --build-from-source

`$ brew install libgeotiff` # --build-from-source

`$ brew install gdal --with-complete`

`$ brew install -v --no-sandbox qgis3 --with-grass  --with-saga-gis-lts`  # other:  --with-r --with-3d

`$ mv /usr/local/opt/qgis3-dev/QGIS.app /Applications/QGIS\ 3.app`

`$ ln -s /Applications/QGIS\ 3.app /usr/local/opt/qgis3-dev/QGIS.app`

To run

Grass: `$ grass74` # in the installation: `ln -s ../Cellar/grass7/7.4.0/bin/grass74 grass74`

Saga:  `$ /usr/local/opt/saga-gis-lts/bin/saga_gui/saga_gui` # you could create a direct link : `ln -s ../Cellar/saga-gis-lts/2.3.2/bin/saga_gui saga_gui`

References:

[http://luisspuerto.net/2018/03/qgis-on-macos-with-homebrew/](http://luisspuerto.net/2018/03/qgis-on-macos-with-homebrew/)

[https://github.com/qgis/homebrew-qgisdev/issues/62](https://github.com/qgis/homebrew-qgisdev/issues/62)

[https://github.com/qgis/homebrew-qgisdev/issues/64](https://github.com/qgis/homebrew-qgisdev/issues/64)

[https://github.com/qgis/homebrew-qgisdev/issues/66](https://github.com/qgis/homebrew-qgisdev/issues/66) 

[https://grasswiki.osgeo.org/wiki/Compiling_on_MacOSX_using_homebrew](https://grasswiki.osgeo.org/wiki/Compiling_on_MacOSX_using_homebrew)

[https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X/](https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X/)
