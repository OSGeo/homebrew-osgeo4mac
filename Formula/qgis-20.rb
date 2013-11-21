require 'formula'

class PyQtImportable < Requirement
  fatal true
  satisfy { quiet_system 'python', '-c', 'from PyQt4 import QtCore' }

  def message
    <<-EOS.undent
      Python could not import the PyQt4 module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The pyqt caveats explain this adjustment and may be reviewed using:

          brew info pyqt
    EOS
  end
end

class Qgis20 < Formula
  homepage 'http://www.qgis.org'
  url 'https://github.com/qgis/QGIS/archive/final-2_0_1.tar.gz'
  version '2.0.1'

  head 'https://github.com/qgis/Quantum-GIS.git', :branch => 'master'

  option 'with-globe', 'Build the globe plugin with osgearth dependencies'
  option 'with-server', 'Build QGIS Server (qgis_mapserv.fcgi)'
  option 'with-postgresql', 'Build with current PostgreSQL client'
  option 'with-api-docs', 'Build the API documentation with Doxygen and Graphviz'
  option 'with-debug', 'Enable debug build (default for --HEAD installs).'

  # core qgis
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  depends_on :python
  depends_on PyQtImportable
  depends_on 'gsl'
  depends_on 'pyqt'
  depends_on 'qscintilla2'
  depends_on 'qwt60'
  depends_on 'expat'
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'fcgi' if build.with? 'server'
  depends_on 'postgresql' => :optional

  # core providers
  depends_on 'gdal'
  # add gdal-shared-plugins (todo, formula for all third-party commercial plugins)
  depends_on 'postgis' => :optional
  # add oracle third-party support (oci, todo)

  # core plugins (c++ and python)
  depends_on 'grass' => :optional
  depends_on 'gdal-grass' if build.with? 'grass' # TODO: check that this is true
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'gpsbabel' => [:optional, '--with-libusb']
  depends_on 'osgearth' => 'with-minizip' if build.with? 'globe'
  depends_on :python => ['psycopg2']
  depends_on 'pyspatialite'
  # add qgis-processing :recommended (todo, formula for all Processing support)
  # add qt-mysql-driver for eVis, not part of bottle (todo)

  def install
    cxxstdlib_check :skip
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.
    args = std_cmake_args.concat %W[
      -DBISON_EXECUTABLE=#{Formula.factory('bison').opt_prefix}/bin/bison
      -DENABLE_TESTS=NO
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_DEV_PREFIX='#{prefix}/Frameworks'
      -DQGIS_MACAPP_INSTALL_DEV=YES
      -DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'
    ]

    if build.with? 'debug' or build.head?
      ENV.O2
      ENV.enable_warnings
      args << '-DCMAKE_BUILD_TYPE=RelWithDebInfo'
    end

    if build.with? 'grass'
      grass = Formula.factory('grass')
      args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{grass.version}'"
      # So that `libintl.h` can be found
      ENV.append 'CXXFLAGS', "-I'#{Formula.factory('gettext').opt_prefix}/include'"
    end

    if build.with? 'globe'
      osg = Formula.factory('open-scene-graph')
      args << "-DWITH_GLOBE=ON"
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    # Avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append 'CXXFLAGS', "-F#{Formula.factory('qt').opt_prefix}/lib"

    python do
      mkdir 'build' do
        system 'cmake', '..', *args
        system 'make install'
      end

      py_lib = lib/"#{python.xy}/site-packages"
      qgis_modules = prefix + 'QGIS.app/Contents/Resources/python/qgis'
      py_lib.mkpath
      ln_s qgis_modules, py_lib + 'qgis'

      # [REPLACE THIS with Info.plist setup, add other env vars: GDAL, OSG, etc.]
      # TODO: add PYQGIS_STARTUP?
      # Create script to launch QGIS app
      (bin + 'qgis').write <<-EOS.undent
        #!/bin/sh
        # Ensure Python modules can be found when QGIS is running.
        env PATH='#{HOMEBREW_PREFIX}/bin':$PATH PYTHONPATH='#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages':$PYTHONPATH\\
          open #{prefix}/QGIS.app
      EOS
    end
  end

  def caveats
    s = <<-EOS.undent
      QGIS has been built as an application bundle. To make it easily available, a
      wrapper script has been written that launches the app with environment
      variables set so that Python modules will be functional:

        qgis

      You may also symlink QGIS.app into ~/Applications:
        brew linkapps
        mkdir -p #{ENV['HOME']}/.MacOSX
        defaults write #{ENV['HOME']}/.MacOSX/environment.plist PYTHONPATH -string "#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages"

      You will need to log out and log in again to make environment.plist effective.

    EOS
    s += python.standard_caveats if python
    s
  end
end
