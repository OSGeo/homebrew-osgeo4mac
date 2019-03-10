---
layout: default
title: Developing on QGIS using OSGeo4Mac
nav_order: 4
---

# Developing on QGIS using OSGeo4Mac

In addition to using this tap to install a [QGIS stable formula](https://github.com/OSGeo/homebrew-osgeo4mac/tree/master/Formula), you can also use it to fully set up a development environment for an externally built QGIS from a clone of the current [development (master) branch](https://github.com/qgis/QGIS) of the source code tree.

> Note: This setup, though heavily tested, is currently _experimental_ and may change. A more stable and time-tested setup is outlined in the QGIS [INSTALL](https://github.com/qgis/QGIS/blob/master/INSTALL) document.

## Development Tools

This tutorial is based upon using the following open source software:
* [Qt Creator](http://qt-project.org/downloads) for CMake/C++ development ([core source](https://github.com/qgis/QGIS/tree/master/src) and [plugins](https://github.com/qgis/QGIS/tree/master/src/plugins))
* [PyCharm Community Edition](http://www.jetbrains.com/pycharm/download/) for Python development ([PyQGIS plugins/apps](http://docs.qgis.org/testing/en/docs/pyqgis_developer_cookbook/), [Python unit tests](https://github.com/qgis/QGIS/tree/master/tests/src/python), [reStructuredText for documentation](https://github.com/qgis/QGIS-Documentation)).

Mac OS X [XCode](https://developer.apple.com/xcode/downloads/) and [Command Line Tools](http://stackoverflow.com/questions/9329243), for Homebrew and building QGIS source. QGIS's [CMake](http://www.cmake.org) build process uses generated Makefiles for building QGIS source directly with `clang`, _not via Xcode project files_, i.e. Xcode.app is not needed for compiling.

## Install Homebrew

See http://brew.sh and [homebrew/wiki/Installation](https://github.com/Homebrew/homebrew/wiki/Installation)

Default install method:
```sh
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
brew update

brew doctor # <-- and fix everything that it mentions, if you can
```

### Homebrew Prefix

While all of the formulae and scripts support building QGIS using a Homebrew non-standard prefix, e.g. `/opt/osgeo4mac`, do yourself a favor (especially if new to Homebrew) and [install in the default directory of `/usr/local`](https://github.com/Homebrew/homebrew/wiki/Installation). QGIS has many dependencies which are available as ["bottles"](https://github.com/Homebrew/homebrew/wiki/Bottles) (pre-built binary installs) from the Homebrew project. Installing Homebrew to a non-standard prefix will force many of the bottled formulae to be built from source, since many of the available bottles are built specific to `/usr/local`. Such unnecessary building can comparatively take hours and hours more, depending upon your available CPU cores.

If desired, this setup supports builds where the OSGeo4Mac deps are in a non-standard Homebrew location, e.g. `/usr/local/osgeo4mac` or `/opt/osgeo4mac`, instead of `/usr/local`. This allows for multiple build scenarios, including placing the dependencies on an external drive, though that requires building all deps with special 'bottle' parameters (see advanced utility [`brew stack`](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/cmd/brew-stack.rb) and its [command line completion](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/etc/bash_completion.d/brew_stack_completion.sh)).

### Install Some Basic Formulae

```
brew install bash-completion
brew install git
```

## Install Python Dependencies

The first important decision to make is regarding whether to use Homebrew's or the OS X system Python. QGIS currently only supports Python 2.5-2.7. Newer Mac system's (>= 10.7) have a version of Python 2.7 installed, so using Homebrew's is unnecessary. However, the more formulae you install, the higher likelihood you will end up running into a formulae that requires installing Homebrew's Python.

> **Important Note:** If you intend to also have the latest [stable version of QGIS and its supporting frameworks from Kyngchaos.com](http://www.kyngchaos.com/software/qgis) installed concurrently with a separate master build of QGIS, it is _highly recommended_ you use Homebrew's Python, since it will allow you to isolate some Python dependencies that may cause crashes, namely modules that link to different supporting libraries. For example, the `osgeo.gdal` and `osgeo.ogr` modules referenced by `/Library/Python/2.7/site-packages/gdal-py2.7.pth` will link to `/Library/Frameworks/GDAL.framework` components instead of to Homebrew's `gdal` formula install.

If using Homebrew Python 2.7, install with:

```sh
brew info python # review options
brew install python # [--with-option ...]
```

Install required Python modules:

* [numpy](https://pypi.python.org/pypi/numpy), [psycopg2](https://pypi.python.org/pypi/psycopg2), [matplotlib](https://pypi.python.org/pypi/matplotlib), [pyparsing](https://pypi.python.org/pypi/pyparsing)

Use [pip](https://pypi.python.org/pypi/pip/1.5.6) with OS X system Python or Homebrew's pip, installed with its Python. You can also tap [homebrew/python](https://github.com/Homebrew/homebrew-python) for some more complex module installs.

_Note:_ a version of NumPy is also vendored (installed internally to keg) by [gdal](https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gdal.rb), if building `--with-python` option, which is the default. You will also want to install a copy to the base `site-packages` for your Python.

Other Python modules installed automatically by Homebrew in next step:

* [sip](https://github.com/Homebrew/homebrew/blob/master/Library/Formula/sip.rb), [PyQt4](https://github.com/Homebrew/homebrew/blob/master/Library/Formula/pyqt.rb), [QScintilla2](https://github.com/Homebrew/homebrew/blob/master/Library/Formula/qscintilla2.rb), [pyspatialite](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/Formula/pyspatialite.rb) (supports libspatialite 4.x), [`osgeo.gdal` and `osgeo.ogr`, etc.](https://github.com/Homebrew/homebrew/blob/master/Library/Formula/gdal.rb)

## Install Build and Linked Library Dependencies

> Note: substitute **`qgis-xx`** for whatever is the [latest stable version of QGIS's formula](https://github.com/OSGeo/homebrew-osgeo4mac/tree/master/Formula), e.g. `qgis-24`.

```sh
brew tap homebrew/science
brew tap osgeo/osgeo4mac
brew info qgis-xx # review options
brew deps --tree qgis-xx --with-grass --with-globe [--with-some-option ...] # to see what dependencies will be included
brew install qgis-xx --only-dependencies --with-grass --with-globe [--with-some-option ...]
```

You do not have to actually do `brew install qgis-xx` unless you also want the stable version installed. If you do have other QGIS formulae installed, and are planning on _installing_ your development build (not just running from the build directory), you should unlink the formula(e) installs, e.g.:

```sh
brew unlink qgis-xx
```
This will ensure the `qgis.core`, etc. Python modules of the formula(e) installs are not overwritten by the development build upon `make install`. All `qgis-xx` formulae QGIS applications will run just fine from their Cellar keg install directory. _Careful_, though, as multiple QGIS installs will probably all share the same application preference files; so, don't run them concurrently.

The `--enable-isolation` option is specific to the `qgis-xx` formulae install, but will have the effect of forcing the use of Homebrew's Python. If you intend to isolate your development build, you can just add `--enable-isolation` when building dependencies, then install the noted required Python modules after the dependencies are built.

### Optional External Dependencies

The [Processing framework](http://docs.qgis.org/testing/en/docs/user_manual/processing/index.html) of QGIS can leverage many external geospatial applications and utilities, which _do not_ need to be built as dependencies prior to building QGIS:

* [`grass-70`](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/Formula/grass-70.rb) (`--with-grass7` option) - [GRASS 7](http://grass.osgeo.org), which is not used by the current GRASS toolbar utility in QGIS (that's GRASS 6)
* [`orfeo-40`](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/Formula/orfeo-40.rb) (`--with-orfeo` option) - [Orfeo Toolbox](http://orfeo-toolbox.org/otb/)
* [`r`](http://www.r-project.org/) (`--with-r` option) - [R Project](http://www.r-project.org/)
* [`saga-gis`](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/Formula/saga-gis.rb) (`--with-saga-gis` option) - [System for Automated Geoscientific Analyses](http://www.saga-gis.org)
* [`taudem`](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/Formula/taudem.rb) - [Terrain Analysis Using Digital Elevation Models](http://hydrology.usu.edu/taudem/taudem5/index.html).

The `gpsbabel` formula is installed as a dependency, though you may have to define the path to its binary when using QGIS's [GPS Tools](http://docs.qgis.org/testing/en/docs/user_manual/working_with_gps/plugins_gps.html).

## Clone QGIS Source

See the QGIS [INSTALL](https://github.com/qgis/QGIS/blob/master/INSTALL) document for information on using git to clone the source tree.

QGIS's build setup uses CMake, which supports 'out-of-source' build directories. It is recommended to create a separate build directory, either within the source tree, or outside it. Since the (re)build process can generate _many_ files, consider creating a separate partition on which to place the build directory. Such a setup can significantly reduce fragmentation on your main startup drive.

## Customize Build Scripts

This tap offers several convenience scripts for use in Qt Creator, or wrapper build scripts, to aid in building/installing QGIS, located at:

```
HOMEBREW_PREFIX/Library/Taps/osgeo/homebrew-osgeo4mac/scripts
```

> Note: **Copy the directory elsewhere** and use it from there. It's important to not edit the scripts where they are located, in the tap, because it is a git repo. You should keep that working tree clean so that `brew update` always works.

The scripts will be used when configuring the QGIS project in Qt Creator.

### Open and review scripts:

> Note: scripts expect the HOMEBREW_PREFIX environment variable to be set, e.g. in your .bash_profile:

  ```bash
  export HOMEBREW_PREFIX=/usr/local
  ```

* [qgis-cmake-options.py](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/scripts/qgis-cmake-options.py) - For generating CMake option string for use in Qt Creator (or build scripts) when built off dependencies from `homebrew-osgeo4mac` tap. Edit CMake options to suit your build needs. Note, the current script usually has CMake options for building QGIS with *all* options that the current `qgis-xx` Homebrew formula supports, which can include things like Oracle support, etc. You will probably want to edit it and comment out such lines for an initial build.

* [qgis-set-app-env.py](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/scripts/qgis-set-app-env.py) - For setting env vars in dev build and installed QGIS.app, to ensure they are available on double-click run. _Needs to stay in the same directory as the next scripts._

* [qgis-creator-build.sh](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/scripts/qgis-creator-build.sh) - Sets up the build environ and ensures the QGIS.app in the build directory can find resources, so it can run from there.

* [qgis-creator-install.sh](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/scripts/qgis-creator-install.sh) - Installs the app and ensures QGIS.app has proper environment variables, so it can be moved around on the filesystem. Currently, QGIS.app bundling beyond [QGIS_MACAPP_BUNDLE=0](https://github.com/qgis/QGIS/tree/master/mac) is not supported. Since all dependencies are in your `HOMEBREW_PREFIX`, no complex bundling is necessary, unless you intend to relocate the built app to another Mac.

### Other Scripts

* [enviro/python_startup.py](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/enviro/python_startup.py) - Strips from Python's `sys.path` any entry that starts with `/Library`, which ensures a Homebrew Python or concurrent install with Kyngchaos's stable is not pulling in conflicting modules from `/Library/Python/2.7/site-packages` or `/Library/Frameworks`. It is not intended to be edited or copied outside of the tap's path, but can be, if you also update the build scripts.

* [enviro/osgeo4mac.env](https://github.com/OSGeo/homebrew-osgeo4mac/blob/master/enviro/osgeo4mac.env) - Is a file intended to be sourced in your bash shell to set up an environment for working with a OSGeo4Mac-enabled Homebrew install. Read the comments at the beginning of the file, and consider adding a custom `~/.osgeo4mac.env` to set things like EDITOR, HOMEBREW_GITHUB_API_TOKEN, and other HOMEBREW_* variables.

## Configure "Build and Run" Preferences in Qt Creator

* Define Homebrew's Qt as an available version:

* Define a new Kit that uses Homebrew's Qt

  If the Xcode Command Line Tools are installed properly, and on Mac OS X 10.9, the LLDB debugger should be found. If not, you may have to locate it.

  If using `clang` and on Mac OS X 10.9, with Qt 4.8.6, you may need to set the Qt mkspec to `unsupported/macx-clang-libc++` due to [changes in the underlying standard C++ libraries](https://github.com/Homebrew/homebrew/wiki/C++-Standard-Libraries). This is not necessary for building QGIS, since it uses CMake. It is important for projects that use the same kit, but build using `qmake`.

* If you installed to a non-standard HOMEBREW_PREFIX, you may have to browse and set the path to the `cmake` executable.

## Open QGIS Source Code as Project in Qt Creator

* Select `File -> Open File or Project...` and browse/open `/path/to/source/of/QGIS/CMakeLists.txt` which opens the CMake Wizard:

* Run `qgis-cmake-options.py` (ensure HOMEBREW_PREFIX environment variable is set) and paste the result in the **Arguments:** field.

* Generate the Unix Makefiles. If there are errors, they will have to be resolved, or the project can not be initialized and opened.

## Configure Project in Qt Creator

Once the project has been initialized, you need to set up the build steps for the QGIS source. While the scripts are not necessary, they reduce the number of build steps needed and simplify building QGIS outside of Qt Creator as well. If you forgo the scripts, you will need to investigate them in order to help set up your own custom build steps.

* Configure project with environment variables and to use the build and install scripts:

  The `make staged-plugins-pyc` (`-j #` is the number of available CPU cores) command stages/installs the core Python plugins to the build directory, so you can run QGIS.app directly from there, without having to run `make install`. It is a separate step to limit what needs rebuilt when editing on core files, which only require rebuilding with the build script once the core plugins have been staged. There is no need to re-stage the core plugins unless something about them has changed.

  * Environment variables

    * **`HOMEBREW_PREFIX`** is referenced and required by the build scripts.
    * **`PATH`** is manually prepended with your `HOMEBREW_PREFIX` (Qt Creator doesn't expand user-set variables). Allows the build process to find required executables, like `sip`.
    * **`PYTHONHOME`**, if using Homebrew's Python, is set to the Current Python framework, manually prepended with your `HOMEBREW_PREFIX`. This keeps Homebrew from importing Python modules located in `/Library/Python/2.7/site-packages` before similar modules in Homebrew's `site-packages`.

## Build QGIS

Select the `all` target and click **Build Project "qgis-x.x.x"**. (Showing the **Compile Output** tab allows log output of the build.)

Unless the source code is unstable, you do not have to `make install`. If the core plugins are staged with `make staged-plugins` or `make staged-plugins-pyc` after the build, you should be able to run the QGIS.app directly from the build directory.

## Run Unit Tests

Open a Terminal.app session and issue the following to run all tests:

```bash
export QGIS_BUILD="/path/to/QGIS/build/dir"
export DYLD_LIBRARY_PATH=${QGIS_BUILD}/output/lib:${QGIS_BUILD}/PlugIns/qgis
export PATH=${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin::/usr/X11/bin
export PYTHONHOME=${HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/2.7
export PYTHONPATH=${HOMEBREW_PREFIX}/lib/python2.7/site-packages
export PYQGIS_STARTUP=${HOMEBREW_PREFIX}/Library/Taps/osgeo/homebrew-osgeo4mac/enviro/python_startup.py
export GDAL_DRIVER_PATH=${HOMEBREW_PREFIX}/lib/gdalplugins

echo "Homebrew:          $HOMEBREW_PREFIX"
echo "DYLD_LIBRARY_PATH: $DYLD_LIBRARY_PATH"
echo "PATH:              $PATH"
echo "PYTHONHOME:        $PYTHONHOME"
echo "PYTHONPATH:        $PYTHONPATH"
echo "PYQGIS_STARTUP:    $PYQGIS_STARTUP"
echo "GDAL_DRIVER_PATH:  $GDAL_DRIVER_PATH"

cd ${QGIS_BUILD}
make test
```

The unit tests do not have a complete success rate across all platforms. See [QGIS CDash reporting site](http://dash.orfeo-toolbox.org/index.php?project=QGIS) for confirmation that any failing tests are, or are not, isolated to your build.

## External Qt Creator Tools

* Consider adding `qgis-cmake-options.py` as an external tool in Qt Creator:

* Consider adding `prepare-commit.sh` as an external tool in Qt Creator:

  If you have done an initial build using CMake option `-D WITH_ASTYLE=TRUE` (default for `qgis-cmake-options.py`) then a `qgisstyle` utility was built and installed to `/path/to/source/of/QGIS/scripts` and the `prepare-commit.sh` script can be used to clean up staged changes _prior_ to committing to locally cloned repository. This fixes up your code and makes it meet syntax guidelines. It is highly recommended you do this prior to your commits that will comprise pull requests to the QGIS project.

## PyCharm Configuration

You can add the `qgis.core`, `qgis.gui`, etc. modules' parent path to the `sys.path` of your PyCharm project's Python interpreter (here using Homebrew's Python):

You will need to add the following `/path/to/QGIS/build/dir/output/python` to access the `qgis` modules.

> Note: Homebrew's Python, by default, includes modules from `/Library/Python/2.7/site-packages` or `/Library/Frameworks`, which can cause conflicts with similar ones from Homebrew. You should consider removing them from `/Library/...` if such a conflict exists.
