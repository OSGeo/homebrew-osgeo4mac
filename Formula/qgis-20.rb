require 'formula'

class QgisDownloadStrategy < GitDownloadStrategy
  # Requires presence of .git to define QGSVERSION
  def support_depth?
    false
  end
end

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

  head 'https://github.com/qgis/QGIS.git', :branch => 'master',
                                           :using => QgisDownloadStrategy

  option 'with-debug', 'Enable debug build (default for --HEAD installs)'
  option 'without-server', 'Build without QGIS Server (qgis_mapserv.fcgi)'
  option 'with-processing', 'Build external utilities used by Processing plugin'
  option 'with-globe', 'Build the Globe plugin, based upon osgEarth'
  option 'without-postgresql', 'Build without current PostgreSQL client'
  option 'with-api-docs', 'Build the API documentation with Doxygen and Graphviz'

  # core qgis
  depends_on 'readline' => :build # fix for formula not being found later on
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  depends_on :python
  depends_on PyQtImportable
  depends_on 'gsl'
  depends_on 'pyqt'
  depends_on 'qscintilla2'
  depends_on 'qwt60' # max of 6.0.2 works with embedded QwtPolar in 2.0.1
  depends_on 'sqlite' # use keg-only install
  depends_on 'expat'
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'fcgi' unless build.without? 'server'
  depends_on 'postgresql' => :recommended # or it uses Apple's old one

  # core providers
  gdalopts = ['enable-mdb', 'enable-unsupported', 'complete']
  gdalopts << 'with-postgresql' if build.with? 'postgresql' or build.with? 'postgis'
  depends_on 'gdal' => gdalopts
  # add gdal-shared-plugins (todo, all third-party commercial plugins)
  depends_on 'postgis' => :optional
  # add oracle third-party support (oci, todo)

  # core plugins (c++ and python)
  depends_on 'grass' => :optional
  depends_on 'gdal-grass' if build.with? 'grass' # TODO: check that this is true
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'gpsbabel' => [:recommended, 'with-libusb']
  depends_on 'osgearth' => 'with-v8' if build.with? 'globe'
  depends_on :python => ['psycopg2', 'numpy']
  depends_on 'pyspatialite' # for DB Manager (broken in PyPi)
  depends_on 'qt-mysql' # driver for eVis, not part of bottle
  # add qgis-processing :recommended (todo, formula for all Processing support)

  if build.include? 'with-api-docs'
    depends_on 'doxygen' => 'with-dot' # with graphviz support
  end

  conflicts_with 'homebrew/science/qgis'

  def linked_version(f)
    if f.rack.directory?
      kegs = f.rack.subdirs.map { |keg| Keg.new(keg) }.sort_by(&:version)
      kegs.each do |keg|
        return keg.version if keg.linked?
      end
#       return "KEG-UNLINKED"
#     else
#       return "MISSING"
    end
    opoo "Unable to determine linked keg version for '#{f}' formula"
  end

  def install
    cxxstdlib_check :skip
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=TRUE
      -Wno-dev
      -DBISON_EXECUTABLE=#{Formula.factory('bison').opt_prefix}/bin/bison
      -DENABLE_TESTS=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_DEV_PREFIX='#{prefix}/Frameworks'
      -DQGIS_MACAPP_INSTALL_DEV=TRUE
      -DPYTHON_CUSTOM_FRAMEWORK='#{python.framework}'
      -DWITH_QSCIAPI=FALSE
      -DWITH_STAGED_PLUGINS=FALSE
    ]

    if build.with? 'debug' or build.head?
      ENV.O2
      ENV.enable_warnings
      args << '-DCMAKE_BUILD_TYPE=RelWithDebInfo'
    else
      args << '-DCMAKE_BUILD_TYPE=None'
    end

    # git is used to find GIT_MARKER in .git/index
    if build.head?
#       args << "-DGITCOMMAND=#{Formula.factory('git').bin}/git"
#       args << "-DGIT_MARKER=#{buildpath}/.git/index"
      args << "-DGIT_MARKER=''"
    end

    args << "-DWITH_MAPSERVER=TRUE" unless build.without? 'server'

    args << "-DPOSTGRES_CONFIG=#{HOMEBREW_PREFIX}/bin/pg_config" if build.with? 'postgresql'

    if build.with? 'grass'
      grass = Formula.factory('grass')
      args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{linked_version(grass)}'"
      # So that `libintl.h` can be found
      ENV.append 'CXXFLAGS', "-I'#{Formula.factory('gettext').opt_prefix}/include'"
    end

    if build.with? 'globe'
      osg = Formula.factory('open-scene-graph')
      args << "-DWITH_GLOBE=TRUE"
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{linked_version(osg)}"
    end

    args << "-DWITH_APIDOC=TRUE" if build.include? 'with-api-docs'

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

      # TODO: write PYQGIS_STARTUP file pyqgis_startup.py

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

    if build.include? 'with-api-docs'
      # TODO: move docs
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
