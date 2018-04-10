require 'formula'
require File.expand_path("../../Requirements/qgis_requirements",
                         Pathname.new(__FILE__).realpath)

class UnlinkedQGIS20 < UnlinkedQGIS
  fatal true
  def qgis_list
    %W[homebrew/science/qgis qgis-18 qgis-22 qgis-24]
  end
  satisfy(:build_env => false) { no_linked_qgis[0] }
end

class Qgis20 < Formula
  homepage 'http://www.qgis.org'
  url 'https://github.com/qgis/QGIS/archive/final-2_0_1.tar.gz'
  sha1 'd532677c1934c3faacd3036af15958b464051853'
  revision 4

  option 'enable-isolation', "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option 'with-debug', 'Enable debug build, which outputs info to system.log or console'
  option 'skip-stdlib-check', 'Build skips checking if dependencies are built against conflicting stdlib.'
  option 'without-server', 'Build without QGIS Server (qgis_mapserv.fcgi)'
  option 'without-postgresql', 'Build without current PostgreSQL client'
  option 'with-globe', 'Build with Globe plugin, based upon osgEarth'
  option 'with-grass', 'Build with GRASS integration plugin support'
  option 'with-postgis', 'Build extra PostGIS geospatial database extender'
  option 'with-oracle', 'Build extra Oracle geospatial database and raster support'
  option 'with-orfeo', 'Build extra Orfeo Toolbox for Processing plugin'
  option 'with-r', 'Build extra R for Processing plugin'
  option 'with-saga-gis', 'Build extra Saga GIS for Processing plugin'
  option 'with-qt-mysql', 'Build extra Qt MySQL plugin for eVis plugin'
  option 'with-api-docs', 'Build the API documentation with Doxygen and Graphviz'
  #option 'persistent-build', 'Maintain the build directory in HOMEBREW_TEMP (--HEAD only)'

  depends_on UnlinkedQGIS20

  # core qgis
  depends_on 'cmake' => :build
  depends_on 'bison' => :build
  if build.with? 'api-docs'
    depends_on 'graphviz' => [:build, 'with-freetype']
    depends_on 'doxygen' => [:build, 'with-dot'] # with graphviz support
  end
  depends_on (build.include? 'enable-isolation' || MacOS.version < :lion ) ? 'python' : :python
  depends_on 'qt'
  depends_on 'pyqt'
  depends_on SipBinary
  depends_on PyQtConfig
  depends_on 'qscintilla2' # will probably be a C++ lib deps in near future
  depends_on 'qwt'
  depends_on 'qwtpolar'
  depends_on 'gsl'
  depends_on 'sqlite' # keg_only
  depends_on 'expat' # keg_only
  depends_on 'proj'
  depends_on 'spatialindex'
  depends_on 'fcgi' if build.with? 'server'
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on 'postgresql' => :recommended

  # core providers
  depends_on 'gdal'
  depends_on 'postgis' => :optional
  depends_on "oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  depends_on "grass-64" => :optional
  depends_on 'gdal-grass' if build.with? 'grass'
  depends_on 'gettext' if build.with? 'grass'
  depends_on 'gpsbabel' => [:recommended, 'with-libusb']
  depends_on 'open-scene-graph' if build.with? 'globe'
  depends_on 'homebrew/science/osgearth' if build.with? 'globe'
  # TODO: remove 'pyspatialite' when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite > 4.1.1 (with mod_spatialite)
  depends_on 'pyspatialite' # for DB Manager
  depends_on 'qt-mysql' => :optional # for eVis plugin (non-functional in 2.0.1?)

  # core processing plugin extras
  # see `postgis` and `grass` above
  depends_on 'orfeo' => :optional
  depends_on 'homebrew/science/r' => :optional
  depends_on 'saga-gis' => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  resource "pyqgis-startup" do
    url "https://gist.githubusercontent.com/dakcarto/11385561/raw/7af66d0c8885a888831da6f12298a906484a1471/pyqgis_startup.py"
    sha1 "13d624e8ccc6bf072bbaeaf68cd6f7309abc1e74"
    version "2.0.0"
  end

  # fixes for stable to work with sip 4.15, remove on release > 2.0.1
  #   see: https://github.com/qgis/QGIS/commit/d27ad33c
  #        https://github.com/qgis/QGIS/commit/641359d3
  #        https://github.com/qgis/QGIS/commit/6f9795b0
  # fix for finding Qt Plugins directory when QGIS_MACAPP_BUNDLE = 0
  #   see: https://github.com/osgeo/homebrew-osgeo4mac/issues/13
  # backport PYQGIS_STARTUP support for isolation, or to avoid Kyngchaos.com
  #   python modules pulling in duplicate linked *.framework libs
  patch do
    url  "https://gist.githubusercontent.com/dakcarto/11231756/raw/8454c7bf118e5672899afadc53f61d252316ce21/qgis-20_fixes.patch"
    sha1 "8bbc5cbca1eaa4befb04b3e8319036c5a263119b"
  end

  def install
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.
    qwt_fw = Formula['qwt'].opt_prefix/"lib/qwt.framework"
    qwtpolar_fw = Formula['qwtpolar'].opt_prefix/"lib/qwtpolar.framework"
    dev_fw = lib/'qgis-dev'
    dev_fw.mkpath
    qsci_opt = Formula['qscintilla2'].opt_prefix
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE=#{(build.with?('debug')) ? 'RelWithDebInfo' : 'None' }
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=TRUE
      -Wno-dev
      -DBISON_EXECUTABLE=#{Formula['bison'].opt_prefix}/bin/bison
      -DENABLE_TESTS=FALSE
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQSCINTILLA_INCLUDE_DIR=#{qsci_opt}/include/Qsci
      -DQSCINTILLA_LIBRARY=#{qsci_opt}/lib/libqscintilla2.dylib
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_DEV_PREFIX='#{dev_fw}'
      -DQGIS_MACAPP_INSTALL_DEV=TRUE
      -DWITH_QSCIAPI=FALSE
      -DWITH_STAGED_PLUGINS=FALSE
    ]

    args << "-DPYTHON_EXECUTABLE='#{python_exec}'"
    # brewed python is used if installed
    if brewed_python?
      args << "-DPYTHON_CUSTOM_FRAMEWORK='#{brewed_python_framework}'"
    end

    args << "-DGIT_MARKER=''" # if release tarball, ends up defined as 'exported'

    args << '-DWITH_MAPSERVER=TRUE' if build.with? 'server'

    pgsql = Formula['postgresql']
    args << "-DPOSTGRES_CONFIG=#{pgsql.opt_prefix}/bin/pg_config" if build.with? 'postgresql'

    if build.with? 'oracle'
      args << '-DWITH_ORACLE=TRUE'
      oracle_opt = Formula['oracle-client-sdk'].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/sdk/include"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    if build.with? 'grass'
      grass = Formula["grass-64"]
      args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{grass.version.to_s}'"
      # So that `libintl.h` can be found
      ENV.append 'CXXFLAGS', "-I'#{Formula['gettext'].opt_prefix}/include'"
    end

    if build.with? 'globe'
      osg = Formula['open-scene-graph']
      opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
      args << '-DWITH_GLOBE=TRUE'
      # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.linked_keg.realpath.basename.to_s}"
    end

    args << '-DWITH_APIDOC=TRUE' if build.with? 'api-docs'

    # Avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append 'CXXFLAGS', "-F#{Formula['qt'].opt_prefix}/lib"

    # TODO: update .app's bundle identifier for HEAD builds
    # (convert to using `defaults`)
    #/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier org.qgis.qgis-dev" "$APPTARGET/Contents/Info.plist"

    # TODO: keep persistent build directory for HEAD builds
    mkdir 'build'

    cd 'build' do
      # fix install fail on stdlib check for Mavericks+, if mixing supporting libs with different stdlibs
      cxxstdlib_check :skip if MacOS.version >= :mavericks and build.include? 'skip-stdlib-check'

      system 'cmake', '..', *args
      #system 'bbedit', 'CMakeCache.txt'
      #raise
      system 'make', 'install'
    end

    py_lib = lib/"python2.7/site-packages"
    qgis_modules = prefix/'QGIS.app/Contents/Resources/python/qgis'
    py_lib.mkpath
    ln_s qgis_modules, py_lib/'qgis'

    ln_s 'QGIS.app/Contents/MacOS/fcgi-bin', prefix/'fcgi-bin' if build.with? 'server'

    doc.mkpath
    mv prefix/'QGIS.app/Contents/Resources/doc/api', doc/'api' if build.with? 'api-docs'
    ln_s prefix/'QGIS.app/Contents/Resources/doc', doc/'doc'

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    libexec.install resource("pyqgis-startup")

    bin.mkdir
    touch "#{bin}/qgis" # so it will be linked into HOMEBREW_PREFIX
  end

  def post_install
    # configure environment variables for .app and launching binary directly.
    # having this in `post_intsall` allows it to be individually run *after* installation with:
    #    `brew postinstall -v qgis-20`

    opts = Tab.for_formula(self).used_options

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = "#{python_site_packages}"
    pths = %W[#{HOMEBREW_PREFIX/'bin'} /usr/bin /bin /usr/sbin /sbin /usr/X11/bin].join(pthsep)

    unless opts.include? 'enable-isolation'
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

    if opts.include? 'with-grass'
      grass = Formula["grass-64"]
      envars[:GRASS_PREFIX] = "#{grass.opt_prefix}/grass-#{grass.version.to_s}"
    end

    if opts.include? 'with-globe'
      osg = Formula['open-scene-graph']
      envars[:OSG_LIBRARY_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.linked_keg.realpath.basename}"
    end

    if opts.include? 'enable-isolation'
      envars[:DYLD_FRAMEWORK_PATH] = "#{HOMEBREW_PREFIX}/Frameworks:/System/Library/Frameworks"
      versioned = %W[
        #{Formula['sqlite'].opt_prefix}/lib
        #{Formula['expat'].opt_prefix}/lib
        #{Formula['libxml2'].opt_prefix}/lib
        #{HOMEBREW_PREFIX}/lib
      ]
      envars[:DYLD_VERSIONED_LIBRARY_PATH] = versioned.join(pthsep)
    end
    if opts.include? 'enable-isolation' or File.exist?("/Library/Frameworks/GDAL.framework")
      # TODO: is PYTHONHOME necessary for isolation, or is it set by embedded interpreter?
      #envars[:PYTHONHOME] = "#{python.framework}/Python.framework/Versions/Current"
      envars[:PYQGIS_STARTUP] = opt_libexec/'pyqgis_startup.py'
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
    envars[:PYTHONPATH] = "#{python_site_packages}" + pthsep + '$PYTHONPATH'
    envars.each { |key, value| bin_cmds << "export #{key.to_s}=#{value}" }
    bin_cmds << opt_prefix/'QGIS.app/Contents/MacOS/QGIS'
    qgis_bin.write(bin_cmds.join("\n"))
    qgis_bin.chmod 0755
  end

  def caveats
    s = <<~EOS
      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in QGIS.app:
        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into /Applications or ~/Applications:
        brew linkapps [--local]

      To run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper script
      pre-defined with Homebrew prefix environment variables:
        #{opt_prefix}/bin/qgis

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app
            bundle they are not.

      For standalone Python development, set the following environment variable:
        export PYTHONPATH=#{python_site_packages}:$PYTHONPATH

      Developer frameworks are installed in:
        #{opt_prefix}/lib/qgis-dev
        NOTE: not symlinked to HOMEBREW_PREFIX/Frameworks, which affects isolation.
              Use dyld -F option in CPPFLAGS/LDFLAGS when building other software.

    EOS

    if build.include? 'enable-isolation'
      s += <<~EOS
        QGIS built with isolation enabled. This allows it to coexist with other
        types of installations of QGIS on your Mac. However, on versions >= 2.0.1,
        this also means Python modules installed in the *system* Python will NOT
        be available to Python processes within QGIS.app.

      EOS
    end

    # check for required run-time Python module dependencies
    # TODO: add 'pyspatialite' when PyPi package supports spatialite 4.x
    xm = []
    %w[psycopg2 matplotlib].each { |m| xm << m unless module_importable? m }
    unless xm.empty?
      s += <<~EOS
        The following Python modules are needed by QGIS during run-time:

            #{xm.join(', ')}

        You can install manually, via installer package or with `pip` (if availble):

            pip install <module>  OR  pip-2.7 install <module>

      EOS
    end
    # TODO: remove this when libqscintilla.dylib becomes core build dependency?
    unless module_importable? 'PyQt4.Qsci'
      s += <<~EOS
        QScintilla Python module is needed by QGIS during run-time.
        Ensure `qscintilla2` formula is linked.

      EOS
    end
    s
  end

  private
  # python utils (deprecated in latest Homebrew)
  # see: https://github.com/Homebrew/homebrew/pull/24842

  #def osx_python?
  #  p = `python -c "import sys; print(sys.prefix)"`.strip
  #  p.start_with?("/System/Library/Frameworks/Python.framework")
  #end

  def brewed_python_framework
    HOMEBREW_PREFIX/"Frameworks/Python.framework/Versions/2.7"
  end

  def brewed_python_framework?
    brewed_python_framework.exist?
  end

  def brewed_python?
    Formula["python"].linked_keg.exist? and brewed_python_framework?
  end

  def python_exec
    if brewed_python?
      brewed_python_framework/"bin/python"
    else
      which("python")
    end
  end

  def python_incdir
    Pathname.new(`#{python_exec} -c 'from distutils import sysconfig; print(sysconfig.get_python_inc())'`.strip)
  end

  def python_libdir
    Pathname.new(`#{python_exec} -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBPL'))"`.strip)
  end

  def python_site_packages
    HOMEBREW_PREFIX/"lib/python2.7/site-packages"
  end

  def module_importable?(mod)
    quiet_system python_exec, "-c", "import #{mod}"
  end
end
