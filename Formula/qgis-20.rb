require 'formula'

class BrewedPython < Requirement
  fatal true

  attr_reader :py_action

  satisfy do
    py = Formula.factory('python')
    installed = py.installed?
    linked = py.linked_keg.exist?
    @py_action = (installed) ? 'link' : 'install'
    installed && linked
  end

  def message
    <<-EOS.undent
        You need to #{@py_action} Hombebrew's Python, then install this formula:

          brew #{@py_action} python

        Or, choose the 'without-brewed-python' formula option.

    EOS
  end
end

class PythonUnlinked < Requirement
  fatal true
  satisfy { !Formula.factory('python').linked_keg.exist? }

  def message
    <<-EOS.undent
        You need to unlik Hombebrew's Python, then install this formula:

          brew unlink python

    EOS
  end
end

class PyQtImportable < Requirement
  fatal true
  satisfy { quiet_system 'python', '-c', 'from PyQt4 import QtCore' }

  def message
    <<-EOS.undent
      Python could not import the PyQt4 module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The `pyqt` caveats explain this adjustment and may be reviewed using:

          brew info pyqt

      Ensure `pyqt` formula is installed and linked.

    EOS
  end
end

class SipBinary < Requirement
  fatal true
  satisfy { which 'sip' }

  def message
    <<-EOS.undent
      The `sip` binary is missing. It is needed to generate the Python bindings for QGIS.
      Ensure `sip` formula is installed and linked.

    EOS
  end
end

class Qgis20 < Formula
  homepage 'http://www.qgis.org'
  url 'https://github.com/qgis/QGIS/archive/final-2_0_1.tar.gz'
  sha1 'd532677c1934c3faacd3036af15958b464051853'

  head 'https://github.com/qgis/QGIS.git', :branch => 'master'

  option 'with-debug', 'Enable debug build/output (default for --HEAD installs)'
  option 'without-brewed-python', "Prefer system Python (default is Homebrew's, if linked)"
  option 'without-server', 'Build without QGIS Server (qgis_mapserv.fcgi)'
  option 'without-postgresql', 'Build without current PostgreSQL client'
  option 'with-globe', 'Build with Globe plugin, based upon osgEarth'
  option 'with-grass', 'Build with GRASS integration plugin support'
  option 'with-postgis', 'Build extra PostGIS geospatial database extender'
  option 'with-orfeo', 'Build extra Orfeo Toolbox for Processing plugin'
  option 'with-r', 'Build extra R for Processing plugin'
  option 'with-saga-gis', 'Build extra Saga GIS for Processing plugin'
  option 'with-qt-mysql', 'Build extra Qt MySQL plugin for eVis plugin'
  option 'with-api-docs', 'Build the API documentation with Doxygen and Graphviz'
#   option 'persistent-build', 'Maintain the build directory in HOMEBREW_TEMP (--HEAD only)'

  # core qgis
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  if build.with? 'api-docs'
    depends_on 'graphviz' => [:build, 'with-freetype']
    depends_on 'doxygen' => [:build, 'with-dot'] # with graphviz support
  end
  # while QGIS can be built without Python support, it is ON by default here
  if build.with? 'brewed-python'
    depends_on BrewedPython
  else
    depends_on PythonUnlinked
  end
  depends_on :python
  depends_on 'qt'
  depends_on 'pyqt'
  depends_on 'qscintilla2' # will probably be a C++ lib deps in near future
  depends_on PyQtImportable
  depends_on SipBinary

  depends_on 'qwt60' # keg_only, max of 6.0.2 works with embedded QwtPolar in QGIS 2.0.1
  # TODO: add QwtPolar 1.1 formula for HEAD builds (then set external CMake options)
  depends_on 'gsl'
  depends_on 'sqlite' # keg_only
  depends_on 'expat' # keg_only
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'fcgi' unless build.without? 'server'
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on 'postgresql' => :recommended

  # core providers
  depends_on 'gdal'
  depends_on 'postgis' => :optional
  # TODO: add Oracle third-party support formula, :optional
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  depends_on 'grass' => :optional
  depends_on 'gdal-grass' if build.with? 'grass'
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'gpsbabel' => [:recommended, 'with-libusb']
  depends_on 'open-scene-graph' if build.with? 'globe'
  depends_on 'osgearth' if build.with? 'globe'
  depends_on 'qt-mysql' => :optional # for eVis plugin (non-functional in 2.0.1?)

  # processing plugin extras
  # see `postgis` and `grass` above
  depends_on 'orfeo' => :optional
  depends_on 'r' => :optional
  depends_on 'saga-gis' => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  conflicts_with 'homebrew/science/qgis'

  # fixes for stable to work with sip 4.15, remove on release > 2.0.1
  # see: https://github.com/qgis/QGIS/commit/d27ad33c
  #      https://github.com/qgis/QGIS/commit/641359d3
  #      https://github.com/qgis/QGIS/commit/6f9795b0
  def patches
    unless build.head?
      'https://gist.github.com/dakcarto/7764118/raw/6cdc678857ae773dceabe6226bfc40ead4f11837/qgis-20_sip-fixes'
    end
  end

  def install
    #raise
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

    if build.with? 'debug' || build.head?
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
      # TODO: update .app's bundle identifier for HEAD builds

      # TODO: keep persistent build directory for HEAD builds
      ##tmpname = File.basename Dir.pwd
      #src = Dir.pwd
      #if build.include? 'persistent-build'
      # cd '..' do
      #   mkdir 'qgis-build' unless File.exists?('qgis-build')
      #   ln_s '../qgis-build', src + '/build'
      #   cd 'qgis-build' do
      #     if File.exists?('CMakeCache.txt')
      #       # swap out any old cache dir path and new temp src directory path
      #       inreplace "CMakeCache.txt" do |s|
      #         s.sub! /(CMAKE_CACHEFILE_DIR:INTERNAL=)(.+)$/, '\1' + Dir.pwd
      #         oldsrc = /(CMAKE_HOME_DIRECTORY:INTERNAL=)(.+)$/.match(s)[2]
      #         s.gsub! oldsrc, src
      #       end
      #     end
      #   end
      # end
      #else
      # mkdir 'build'
      #end

      mkdir 'build'

      cd 'build' do
        system 'cmake', '..', *args
        #system 'bbedit', 'CMakeCache.txt'
        #raise
        system 'make install'
      end

      py_lib = lib/"#{python.xy}/site-packages"
      qgis_modules = prefix/'QGIS.app/Contents/Resources/python/qgis'
      py_lib.mkpath
      ln_s qgis_modules, py_lib/'qgis'

      # TODO: define default env vars, relative to whether or not to isolate

      # TODO: write PYQGIS_STARTUP file pyqgis_startup.py, if isolating

      # TODO: add Info.plist setup, add other env vars: GDAL, OSG, etc.

      # TODO: rewrite this only for running QGIS.app/Contents/MacOS/QGIS directly
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
    # TODO: complete rewrite, not using .MacOSX/environment.plist hack
    s = ''
    # check for required run-time Python module dependencies
    # TODO: add 'pyspatialite' dep for DB Manager (currently being updated by developer)
    xm = []
    %w[psycopg2].each { |m| xm << m unless python.importable? m }
    unless xm.empty?
      s += <<-EOS.undent
        The following Python modules are needed by QGIS during run-time:

            #{xm.join(', ')}

        You can install manually, via installer package or with `pip` (if availble):

            pip install <module>  OR  pip-2.7 install <module>

      EOS
    end
    # TODO: remove this when libqscintilla.dylib becomes core build dependency?
    unless python.importable? 'PyQt4.Qsci'
      s += <<-EOS.undent
        QScintilla Python module is needed by QGIS during run-time.
        Ensure `qscintilla2` formula is linked.

      EOS
    end

    s += <<-EOS.undent
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
