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

class SipBinary < Requirement
  fatal true
  #noinspection RubyResolve
  default_formula 'sip'
  satisfy { which 'sip' }

  def message
    <<-EOS.undent
      The `sip` binary is missing. It is needed to generate the Python bindings for QGIS.
      Ensure `sip` formula is installed and linked.

    EOS
  end
end

class PyQtConfig < Requirement
  fatal true
  #noinspection RubyResolve
  default_formula 'pyqt'
  # pyqtconfig is not created with PyQt4 >= 4.10.x when using configure-ng.
  # Homebrew's `pyqt` formula corrects this. Remains an issue until QGIS project
  # adjusts FindPyQt.py in CMake setup to work with configure-ng.
  satisfy { quiet_system 'python', '-c', 'from PyQt4 import pyqtconfig' }

  def message
    <<-EOS.undent
      Python could not import the PyQt4.pyqtconfig module. This will cause the QGIS build to fail.
      The most common reason for this failure is that the PYTHONPATH needs to be adjusted.
      The `pyqt` caveats explain this adjustment and may be reviewed using:

          brew info pyqt

      Ensure `pyqt` formula is installed and linked, and that it includes the `pyqtconfig` module.

    EOS
  end
end

class Qgis20 < Formula
  homepage 'http://www.qgis.org'
  url 'https://github.com/qgis/QGIS/archive/final-2_0_1.tar.gz'
  sha1 'd532677c1934c3faacd3036af15958b464051853'

  head 'https://github.com/qgis/QGIS.git', :branch => 'master'

  option 'enable-isolation', "Isolate .app's environment to HOMEBRE_PREFIX, to coexist with other QGIS installs"
  option 'with-debug', 'Enable debug build, which outputs info to system.log or console'
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
  #option 'persistent-build', 'Maintain the build directory in HOMEBREW_TEMP (--HEAD only)'

  # core qgis
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  if build.with? 'api-docs'
    depends_on 'graphviz' => [:build, 'with-freetype']
    depends_on 'doxygen' => [:build, 'with-dot'] # with graphviz support
  end
  # while QGIS can be built without Python support, it is ON by default here
  if build.with?('brewed-python') || build.include?('enable-isolation')
    depends_on BrewedPython
  else
    depends_on PythonUnlinked
  end
  depends_on :python
  depends_on 'qt'
  depends_on SipBinary
  depends_on PyQtConfig
  depends_on 'qscintilla2' # will probably be a C++ lib deps in near future
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
  # TODO: remove 'pyspatialite' when PyPi package supports spatialite 4.x
  depends_on 'pyspatialite' # for DB Manager
  depends_on 'qt-mysql' => :optional # for eVis plugin (non-functional in 2.0.1?)

  # core processing plugin extras
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
    dev_fw = lib/'qgis-dev'
    dev_fw.mkpath
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE=#{(build.with?('debug')) ? 'RelWithDebInfo' : 'None' }
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=TRUE
      -Wno-dev
      -DBISON_EXECUTABLE=#{Formula.factory('bison').opt_prefix}/bin/bison
      -DENABLE_TESTS=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_DEV_PREFIX='#{dev_fw}'
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
      # (convert to using `defaults`)
      #/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier org.qgis.qgis-dev" "$APPTARGET/Contents/Info.plist"

      # TODO: keep persistent build directory for HEAD builds
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
    end

    # symlink dev frameworks, so failed installs don't block future installs
    frameworks.mkpath
    ln_sf Dir["#{dev_fw}/*.framework"], frameworks

    ln_s 'QGIS.app/Contents/MacOS/fcgi-bin', prefix/'fcgi-bin' if build.with? 'server'

    doc.mkpath
    mv prefix/'QGIS.app/Contents/Resources/doc/api', doc/'api' if build.with? 'api-docs'
    ln_s prefix/'QGIS.app/Contents/Resources/doc', doc/'doc'

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # TODO: change to gist resource?
    cp HOMEBREW_PREFIX/'Library/Taps/dakcarto-osgeo4mac/enviro/python_startup.py', prefix/'pyqgis_startup.py'

    bin.mkdir
    touch "#{bin}/qgis" # so it will be linked into HOMEBREW_PREFIX
  end

  def post_install
    # configure environment variables for .app and launching binary directly.
    # having this in `post_intsall` allows it to be individually run *after* installation with:
    #    `brew postinstall -v qgis-20 [--option --option ...]`

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = "#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages"
    pths = %W[#{HOMEBREW_PREFIX/'bin'} /usr/bin /bin /usr/sbin /sbin /usr/X11/bin].join(pthsep)

    unless build.include? 'enable-isolation'
      pths = ORIGINAL_PATHS.join(pthsep)
      unless pths.include? HOMEBREW_PREFIX/'bin'
        pths = HOMEBREW_PREFIX/'bin' + pthsep + pths
      end
      pyenv = ENV['PYTHONPATH']
      if pyenv
        pypth = (pyenv.include?(pypth)) ? pyenv : pypth + pthsep + pyenv
      end
    end

    envars = {
      :PATH => "#{pths}",
      :PYTHONPATH => "#{pypth}",
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    }

    if build.with? 'grass'
      grass = Formula.factory('grass')
      envars[:GRASS_PREFIX] = "#{grass.opt_prefix}/grass-#{grass.linked_keg.realpath.basename}"
    end

    if build.with? 'globe'
      osg = Formula.factory('open-scene-graph')
      envars[:OSG_PLUGINS_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.linked_keg.realpath.basename}"
    end

    if build.include? 'enable-isolation'
      envars[:DYLD_FRAMEWORK_PATH] = "#{HOMEBREW_PREFIX}/Frameworks:/System/Library/Frameworks"
      versioned = %W[
        #{Formula.factory('sqlite').opt_prefix}/lib
        #{Formula.factory('expat').opt_prefix}/lib
        #{Formula.factory('libxml2').opt_prefix}/lib
        #{Formula.factory('qwt60').opt_prefix}/lib
        #{HOMEBREW_PREFIX}/lib
      ]
      envars[:DYLD_VERSIONED_LIBRARY_PATH] = versioned.join(pthsep)
      # TODO: is PYTHONHOME necessary for isolation, or is it set by embedded interpreter?
      #envars[:PYTHONHOME] = "#{python.framework}/Python.framework/Versions/Current"
      envars[:PYQGIS_STARTUP] = opt_prefix/'pyqgis_startup.py' # only works with QGIS > 2.0.1
    end

    #envars.each { |key, value| puts "#{key.to_s}=#{value}" }
    #exit

    # add env vars to QGIS.app's Info.plist, in LSEnvironment section
    app = prefix/'QGIS.app'
    plst = app/'Contents/Info.plist'
    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: may not be what you want, if .app already has LSEnvironment settings
    dflt = quiet_system "defaults read-type \"#{plst}\" LSEnvironment"
    system "defaults delete \"#{plst}\" LSEnvironment" if dflt
    kv = '{ '
    envars.each { |key, value| kv += "'#{key.to_s}' = '#{value}'; " }
    kv += '}'
    system "defaults write \"#{plst}\" LSEnvironment \"#{kv}\""
    # leave the plist readable; convert from binary to XML format
    system "plutil -convert xml1 -- \"#{plst}\""
    # update modification date on app bundle, or changes won't take effect
    system "touch \"#{app}\""

    # add env vars to launch script for QGIS app's binary
    qgis_bin = bin/'qgis'
    rm_f qgis_bin if File.exists?(qgis_bin) # install generates empty file
    bin_cmds = %W[#!/bin/sh\n]
    # setup shell-prepended env vars (may result in duplication of paths)
    envars[:PATH] = "#{HOMEBREW_PREFIX}/bin" + pthsep + '$PATH'
    envars[:PYTHONPATH] = "#{HOMEBREW_PREFIX}/lib/#{python.xy}/site-packages" + pthsep + '$PYTHONPATH'
    envars.each { |key, value| bin_cmds << "export #{key.to_s}=#{value}" }
    bin_cmds << opt_prefix/'QGIS.app/Contents/MacOS/QGIS'
    qgis_bin.write(bin_cmds.join("\n"))
    qgis_bin.chmod 0755
  end

  def caveats
    s = <<-EOS.undent
      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix have been embedded in QGIS.app:

        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into ~/Applications:

        brew linkapps

      To run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper script
      pre-defined with Homebrew prefix environment variables:

        #{opt_prefix}/bin/qgis

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app bundle will not.

    EOS
    s += python.standard_caveats if python

    if build.include? 'enable-isolation'
      s += <<-EOS.undent
        QGIS built with isolation enabled. This allows it to coexist with other
        types of installations of QGIS on your Mac. However, on versions >= 2.0.1,
        this also means Python modules installed in the *system* Python will NOT
        be available to Python processes within QGIS.app.

      EOS
    end

    # check for required run-time Python module dependencies
    # TODO: add 'pyspatialite' when PyPi package supports spatialite 4.x
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
    s
  end
end
