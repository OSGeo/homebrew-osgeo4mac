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
  sha1 'd532677c1934c3faacd3036af15958b464051853'

  head 'https://github.com/qgis/QGIS.git', :branch => 'master'

  option 'with-debug', 'Enable debug build (default for --HEAD installs)'
  option 'without-server', 'Build without QGIS Server (qgis_mapserv.fcgi)'
  option 'with-processing-extras', 'Build extra utilities used by Processing plugin'
  option 'with-globe', 'Build the Globe plugin, based upon osgEarth'
  option 'without-postgresql', 'Build without current PostgreSQL client'
  option 'with-qt-mysql', 'Build extra Qt MySQL plugin for QGIS\'s eVis plugin'
  option 'with-api-docs', 'Build the API documentation with Doxygen and Graphviz'
#   option 'persistent-build', 'Maintain the build directory in HOMEBREW_TEMP (--HEAD only)'

  # core qgis
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  depends_on :python # => %w[psycopg2 numpy]
  depends_on PyQtImportable
  if build.with? 'api-docs'
    depends_on 'graphviz' => 'with-freetype'
    depends_on 'doxygen' => 'with-dot' # with graphviz support
  end
  depends_on 'pyqt'
  depends_on 'qscintilla2'
  depends_on 'gsl'
  depends_on 'qwt60' # max of 6.0.2 works with embedded QwtPolar in QGIS 2.0.1
  depends_on 'sqlite' # use keg-only install
  depends_on 'expat'
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'fcgi' unless build.without? 'server'
  depends_on 'postgresql' => :recommended # or might use Apple's much older client

  # core providers
  #gdalopts = %w[enable-unsupported complete]
  #gdalopts << 'with-postgresql' if build.with? 'postgresql' or build.with? 'postgis'
  #depends_on 'gdal' => gdalopts unless Formula.factory('gdal').installed?
  depends_on 'gdal'
  # add gdal shared plugins (todo, all third-party commercial plugins)
  depends_on 'postgis' => (build.with? 'processing-extras') ? :recommended : :optional
  # add oracle third-party support (oci, todo)

  # core plugins (c++ and python)
  depends_on 'grass' => (build.with? 'processing-extras') ? :recommended : :optional
  depends_on 'gdal-grass' if build.with? 'grass' # TODO: check that this is required for QGIs plugin
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'gpsbabel' => [:recommended, 'with-libusb']
  depends_on 'osgearth' => 'with-v8' if build.with? 'globe'
  #depends on 'pyspatialite' # for DB Manager (currently being updated: )
  depends_on 'qt-mysql' => :optional
  if build.with? 'processing-extras'
    # depends on `postgis` and `grass`, see above
    depends_on 'orfeo'
    depends_on 'openblas'
    depends_on 'r' => 'with-openblas'
    depends_on 'saga-gis' => 'disable-gui'
    # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
    # TODO: Fusion from USFS (via `wine`?)
  end

  conflicts_with 'homebrew/science/qgis'

  # fixes for stable to work with sip 4.15, remove on release > 2.0.1
  # see: https://github.com/qgis/QGIS/commit/d27ad33c
  #      https://github.com/qgis/QGIS/commit/641359d3
  #      https://github.com/qgis/QGIS/commit/6f9795b0
  def patches
    unless build.head?
      # TODO: set to specific hash when done updating
      'https://gist.github.com/dakcarto/7764118/raw'
    end
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
      -DWITH_QSCIAPI=FALSE
      -DWITH_STAGED_PLUGINS=FALSE
    ]

    unless python.from_osx?
      if python.framework?
        args << "-DPYTHON_CUSTOM_FRAMEWORK='#{python.framework}/Python.framework'"
      else
        args << "-DPYTHON_INCLUDE_DIR='#{python.incdir}'"
        args << "-DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'"
      end
    end

    if build.with? 'debug' or build.head?
      ENV.enable_warnings
      args << '-DCMAKE_BUILD_TYPE=RelWithDebInfo'
    else
      args << '-DCMAKE_BUILD_TYPE=None'
    end

    # find git revision for HEAD build
    if build.head? && File.exists?("#{cached_download}/.git/index")
      args << "-DGITCOMMAND=#{Formula.factory('git').bin}/git"
      args << "-DGIT_MARKER=#{cached_download}/.git/index"
    else
      args << "-DGIT_MARKER=''" # if git clone borked, or release tarball, ends up defined as 'exported'
    end

    args << '-DWITH_MAPSERVER=TRUE' unless build.without? 'server'

    pgsql = Formula.factory('postgresql')
    args << "-DPOSTGRES_CONFIG=#{pgsql.opt_prefix}/bin/pg_config" if build.with? 'postgresql'

    if build.with? 'grass'
      grass = Formula.factory('grass')
      opoo "`grass` formula's keg not linked." unless grass.linked_keg.exist?
      args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{grass.linked_keg.realpath.basename.to_s}'"
      # So that `libintl.h` can be found
      ENV.append 'CXXFLAGS', "-I'#{Formula.factory('gettext').opt_prefix}/include'"
    end

    if build.with? 'globe'
      osg = Formula.factory('open-scene-graph')
      opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
      args << '-DWITH_GLOBE=TRUE'
      # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.linked_keg.realpath.basename.to_s}"
    end

    args << '-DWITH_APIDOC=TRUE' if build.with? 'api-docs'

    # Avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append 'CXXFLAGS', "-F#{Formula.factory('qt').opt_prefix}/lib"

    python do
#       #tmpname = File.basename Dir.pwd
#       src = Dir.pwd
#       if build.include? 'persistent-build'
#         cd '..' do
#           mkdir 'qgis-build' unless File.exists?('qgis-build')
#           ln_s '../qgis-build', src + '/build'
#           cd 'qgis-build' do
#             if File.exists?('CMakeCache.txt')
#               # swap out any old cache dir path and new temp src directory path
#               inreplace "CMakeCache.txt" do |s|
#                 s.sub! /(CMAKE_CACHEFILE_DIR:INTERNAL=)(.+)$/, '\1' + Dir.pwd
#                 oldsrc = /(CMAKE_HOME_DIRECTORY:INTERNAL=)(.+)$/.match(s)[2]
#                 s.gsub! oldsrc, src
#               end
#             end
#           end
#         end
#       else
#         mkdir 'build'
#       end
      mkdir 'build'

      cd 'build' do
        system 'cmake', '..', *args
        #system 'bbedit', 'CMakeCache.txt'
        #raise ''
        #exit
        system 'make install'
      end

      py_lib = lib/"#{python.xy}/site-packages"
      qgis_modules = prefix/'QGIS.app/Contents/Resources/python/qgis'
      py_lib.mkpath
      ln_s qgis_modules, py_lib/'qgis'

      # TODO: write PYQGIS_STARTUP file pyqgis_startup.py

      # [REPLACE THIS with Info.plist setup, add other env vars: GDAL, OSG, etc.]
      # Create script to launch QGIS app
      (bin + 'qgis').write <<-EOS.undent
        #!/bin/sh
        # Ensure Python modules can be found when QGIS is running.
        env PATH='#{HOMEBREW_PREFIX}/bin':$PATH PYTHONPATH='#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages':$PYTHONPATH\\
          open #{prefix}/QGIS.app
      EOS
    end

    ln_s 'QGIS.app/Contents/MacOS/fcgi-bin', prefix/'fcgi-bin' if build.with? 'server'

    doc.mkpath
    mv prefix/'QGIS.app/Contents/Resources/doc/api', doc/'api' if build.with? 'api-docs'
    ln_s prefix/'QGIS.app/Contents/Resources/doc', doc/'doc'

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
