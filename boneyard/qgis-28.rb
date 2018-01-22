require File.expand_path("../../Requirements/qgis_requirements",
                         Pathname.new(__FILE__).realpath)

class UnlinkedQGIS28 < UnlinkedQGIS
  fatal true
  def qgis_formula_name
    "qgis-28"
  end
  satisfy(:build_env => false) { no_linked_qgis[0] }
end

class Qgis28 < Formula
  desc "Open Source Geographic Information System"
  homepage "http://www.qgis.org"
  url "https://github.com/qgis/QGIS/archive/final-2_8_9.tar.gz"
  sha256 "7bfc6fa2221ec7fc809c0cacc5ef821f6d3b6d8d8254b4cee8fd9c452731e3d6"

  bottle do
    # root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    # sha256 "6a2d89239b8da548a765beb839d428a81d1a1b34c3e64d8fe4c8699993aff7ef" => :mavericks
    # sha256 "15210d5e07cf9bfe1de8a042c5ddee82acf41b94adb28909a9c79dd6582e91c2" => :yosemite
  end

  def pour_bottle?
    brewed_python?
  end

  head "https://github.com/qgis/QGIS.git", :branch => "release-2_8"

  option "enable-isolation", "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option "with-debug", "Enable debug build, which outputs info to system.log or console"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "with-globe", "Build with Globe plugin, based upon osgEarth"
  option "without-postgis", "Build without extra PostGIS geospatial database extender"
  option "without-grass", "Build without GRASS 6 integration plugin and Processing plugin support"
  option "with-grass7", "Build with GRASS 7 for Processing plugin"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-orfeo", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga-gis", "Build extra Saga GIS for Processing plugin"
  option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"

  depends_on UnlinkedQGIS28

  # core qgis
  depends_on "cmake" => :build
  depends_on "bison" => :build
  if build.with? "api-docs"
    depends_on "graphviz" => [:build, "with-freetype"]
    depends_on "doxygen" => [:build, "with-dot"] # with graphviz support
  end
  depends_on (build.include? "enable-isolation" || MacOS.version < :lion ) ? "python" : :python
  depends_on "qt"
  depends_on "pyqt"
  depends_on SipBinary
  depends_on PyQtConfig
  depends_on "qscintilla2" # will probably be a C++ lib deps in near future
  depends_on "qwt"
  depends_on "qwtpolar"
  depends_on "gsl"
  depends_on "sqlite" # keg_only
  depends_on "expat" # keg_only
  depends_on "proj"
  depends_on "spatialindex"
  depends_on "fcgi" if build.with? "server"
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on "postgresql" => :recommended

  # core providers
  depends_on "gdal"
  depends_on "postgis" => :recommended
  depends_on "oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with? "grass"
    depends_on "grass-64"
    depends_on "gdal-grass64"
    depends_on "gettext"
  end

  if build.with? "globe"
    depends_on "open-scene-graph" => ["with-qt"]
    depends_on "homebrew/science/osgearth"
  end
  depends_on "gpsbabel" => [:recommended, "with-libusb"]
  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)
  depends_on "pyspatialite" # for DB Manager
  depends_on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `postgis` and `grass` above
  depends_on "grass-70" if build.with? "grass7"
  depends_on "orfeo-42" if build.with? "orfeo"
  depends_on "homebrew/science/r" => :optional
  depends_on "saga-gis" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  resource "pyqgis-startup" do
    url "https://gist.githubusercontent.com/dakcarto/11385561/raw/7af66d0c8885a888831da6f12298a906484a1471/pyqgis_startup.py"
    sha256 "3d0adca0c8684f3d907c626fc86d93d73165e184960d16ae883fca665ecc32e6"
    version "2.0.0"
  end

  # patches that represent all backports to release-2_8 branch
  # see: https://github.com/qgis/QGIS/commits/release-2_8
  # stable do
  #   patch do
  #     # since 2.8.9 tag thru ---, minus windows-formatted patches
  #     url ""
  #     sha256 ""
  #   end
  # end

  def install
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.
    qwt_fw = Formula["qwt"].opt_lib/"qwt.framework"
    qwtpolar_fw = Formula["qwtpolar"].opt_lib/"qwtpolar.framework"
    dev_fw = lib/"qgis-dev"
    dev_fw.mkpath
    qsci_opt = Formula["qscintilla2"].opt_prefix
    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override
    args += %W[
      -DBISON_EXECUTABLE=#{Formula["bison"].opt_bin}/bison
      -DENABLE_TESTS=FALSE
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQSCINTILLA_INCLUDE_DIR=#{qsci_opt}/include
      -DQSCINTILLA_LIBRARY=#{qsci_opt}/lib/libqscintilla2.dylib
      -DQSCI_SIP_DIR=#{qsci_opt}/share/sip
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

    # find git revision for HEAD build
    if build.head? && File.exists?("#{cached_download}/.git/index")
      args << "-DGITCOMMAND=#{Formula["git"].opt_bin}/git"
      args << "-DGIT_MARKER=#{cached_download}/.git/index"
    else
      args << "-DGIT_MARKER=''" # if git clone borked, or release tarball, ends up defined as 'exported'
    end

    args << "-DWITH_SERVER=#{build.with?("server") ? "TRUE" : "FALSE"}"
    if build.with? "server"
      fcgi_opt = Formula["fcgi"].opt_prefix
      args << "-DFCGI_INCLUDE_DIR=#{fcgi_opt}/include"
      args << "-DFCGI_LIBRARY=#{fcgi_opt}/lib/libfcgi.dylib"
    end

    args << "-DPOSTGRES_CONFIG=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"

    args << "-DWITH_GRASS=#{build.with?("grass") ? "TRUE" : "FALSE"}"
    if build.with? "grass"
      # this is to build the GRASS Plugin, not for Processing plugin support
      grass = Formula["grass-64"]
      args << "-DGRASS_PREFIX='#{grass.opt_prefix}/grass-#{grass.version.to_s}'"
      # So that `libintl.h` can be found
      ENV.append "CXXFLAGS", "-I'#{Formula["gettext"].opt_include}'"
    end

    args << "-DWITH_GLOBE=#{build.with?("globe") ? "TRUE" : "FALSE"}"
    if build.with? "globe"
      osg = Formula["open-scene-graph"]
      opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
      # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version.to_s}"
    end

    args << "-DWITH_ORACLE=#{build.with?("oracle") ? "TRUE" : "FALSE"}"
    if build.with? "oracle"
      oracle_opt = Formula["oracle-client-sdk"].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/sdk/include"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    args << "-DWITH_APIDOC=#{build.with?("api-docs") ? "TRUE" : "FALSE"}"

    # Avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append "CXXFLAGS", "-F#{Formula["qt"].opt_lib}"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = "#{brewed_python_framework}" if brewed_python?

    mkdir "build" do
      system "cmake", "..", *args
      #system "bbedit", "CMakeCache.txt"
      #raise
      system "make", "install"
    end

    # Update .app's bundle identifier, so Kyngchaos.com installer doesn't get confused
    inreplace prefix/"QGIS.app/Contents/Info.plist",
              "org.qgis.qgis2", "org.qgis.qgis2-hb#{build.head? ? "-dev" : ""}"

    py_lib = lib/"python2.7/site-packages"
    py_lib.mkpath
    ln_s "../../../QGIS.app/Contents/Resources/python/qgis", py_lib/"qgis"

    ln_s "QGIS.app/Contents/MacOS/fcgi-bin", prefix/"fcgi-bin" if build.with? "server"

    doc.mkpath
    mv prefix/"QGIS.app/Contents/Resources/doc/api", doc/"api" if build.with? "api-docs"
    ln_s "../../../QGIS.app/Contents/Resources/doc", doc/"doc"

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    libexec.install resource("pyqgis-startup")

    bin.mkdir
    touch "#{bin}/qgis" # so it will be linked into HOMEBREW_PREFIX
    post_install
  end

  def post_install
    # configure environment variables for .app and launching binary directly.
    # having this in `post_intsall` allows it to be individually run *after* installation with:
    #    `brew postinstall -v qgis-XX` <-- where XX is formula version

    app = prefix/"QGIS.app"
    tab = Tab.for_formula(self)
    opts = tab.used_options
    bottle_poured = tab.poured_from_bottle

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = "#{python_site_packages}"
    pths = %W[#{HOMEBREW_PREFIX/"bin"} /usr/bin /bin /usr/sbin /sbin /opt/X11/bin /usr/X11/bin].join(pthsep)

    unless opts.include? "enable-isolation"
      pths = ORIGINAL_PATHS.join(pthsep)
      unless pths.include? HOMEBREW_PREFIX/"bin"
        pths = HOMEBREW_PREFIX/"bin" + pthsep + pths
      end
      pyenv = ENV["PYTHONPATH"]
      if pyenv
        pypth = (pyenv.include?(pypth)) ? pyenv : pypth + pthsep + pyenv
      end
    end

    # set install's lib/python2.7/site-packages first, so app will work if unlinked
    pypth = "#{lib}/python2.7/site-packages" + pthsep + pypth

    envars = {
      :PATH => "#{pths}",
      :PYTHONPATH => "#{pypth}",
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    }

    proc_algs = "Contents/Resources/python/plugins/processing/algs"
    unless opts.include? "without-grass"
      grass = Formula["grass-64"]
      envars[:GRASS_PREFIX] = "#{grass.opt_prefix}/grass-#{grass.version.to_s}"
      begin
        inreplace app/"#{proc_algs}/grass/GrassUtils.py",
                  "/Applications/GRASS-6.4.app/Contents/MacOS",
                  HOMEBREW_PREFIX/"opt/grass-64/grass-base" unless bottle_poured
      rescue Utils::InreplaceError
        puts "GRASS 6 GrassUtils already updated"
      end

    end

    if opts.include? "with-grass7"
      begin
        inreplace app/"#{proc_algs}/grass7/Grass7Utils.py",
                  "/Applications/GRASS-7.0.app/Contents/MacOS",
                  HOMEBREW_PREFIX/"opt/grass-70/grass-base"
      rescue Utils::InreplaceError
        puts "GRASS 7 GrassUtils already updated"
      end
    end

    unless opts.include? "without-globe"
      osg = Formula["open-scene-graph"]
      envars[:OSG_LIBRARY_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version.to_s}"
    end

    if opts.include? "enable-isolation"
      envars[:DYLD_FRAMEWORK_PATH] = "#{HOMEBREW_PREFIX}/Frameworks:/System/Library/Frameworks"
      versioned = %W[
        #{Formula["sqlite"].opt_lib}
        #{Formula["expat"].opt_lib}
        #{Formula["libxml2"].opt_lib}
        #{HOMEBREW_PREFIX}/lib
      ]
      envars[:DYLD_VERSIONED_LIBRARY_PATH] = versioned.join(pthsep)
    end
    if opts.include? "enable-isolation" or File.exist?("/Library/Frameworks/GDAL.framework")
      envars[:PYQGIS_STARTUP] = opt_libexec/"pyqgis_startup.py"
    end

    #envars.each { |key, value| puts "#{key.to_s}=#{value}" }
    #exit

    # add env vars to QGIS.app's Info.plist, in LSEnvironment section
    plst = app/"Contents/Info.plist"
    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: may not be what you want, if .app already has LSEnvironment settings
    dflt = quiet_system "defaults read-type \"#{plst}\" LSEnvironment"
    system "defaults delete \"#{plst}\" LSEnvironment" if dflt
    kv = "{ "
    envars.each { |key, value| kv += "'#{key.to_s}' = '#{value}'; " }
    kv += "}"
    system "defaults write \"#{plst}\" LSEnvironment \"#{kv}\""
    # leave the plist readable; convert from binary to XML format
    system "plutil -convert xml1 -- \"#{plst}\""
    # update modification date on app bundle, or changes won't take effect
    touch "#{app}"

    # add env vars to launch script for QGIS app's binary
    qgis_bin = bin/"qgis"
    rm_f qgis_bin if File.exists?(qgis_bin) # install generates empty file
    bin_cmds = %W[#!/bin/sh\n]
    # setup shell-prepended env vars (may result in duplication of paths)
    envars[:PATH] = "#{HOMEBREW_PREFIX}/bin" + pthsep + "$PATH"
    envars[:PYTHONPATH] = "#{python_site_packages}" + pthsep + "$PYTHONPATH"
    envars.each { |key, value| bin_cmds << "export #{key.to_s}=#{value}" }
    bin_cmds << opt_prefix/"QGIS.app/Contents/MacOS/QGIS \"$@\""
    qgis_bin.write(bin_cmds.join("\n"))
    qgis_bin.chmod 0755
  end

  def caveats
    s = <<~EOS
      Bottles support only Homebrew's Python

      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in QGIS.app:
        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into /Applications or ~/Applications:
        brew linkapps [--local]

      To directly run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper
      script pre-defined with Homebrew prefix environment variables:
        #{opt_bin}/qgis

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app
            bundle they are not.

      For standalone Python development, set the following environment variable:
        export PYTHONPATH=#{python_site_packages}:$PYTHONPATH

      Developer frameworks are installed in:
        #{opt_lib}/qgis-dev
        NOTE: not symlinked to HOMEBREW_PREFIX/Frameworks, which affects isolation.
              Use dyld -F option in CPPFLAGS/LDFLAGS when building other software.

    EOS

    if build.include? "enable-isolation"
      s += <<~EOS
        QGIS built with isolation enabled. This allows it to coexist with other
        types of installations of QGIS on your Mac. However, on versions >= 2.0.1,
        this also means Python modules installed in the *system* Python will NOT
        be available to Python processes within QGIS.app.

      EOS
    end

    # check for required run-time Python module dependencies
    # TODO: add "pyspatialite" when PyPi package supports spatialite 4.x
    xm = []
    %w[psycopg2 matplotlib pyparsing].each {
        |m| xm << m unless module_importable? m
    }
    unless xm.empty?
      s += <<~EOS
        The following Python modules are needed by QGIS during run-time:

            #{xm.join(", ")}

        You can install manually, via installer package or with `pip` (if availble):

            pip install <module>  OR  pip-2.7 install <module>

      EOS
    end
    # TODO: remove this when libqscintilla.dylib becomes core build dependency?
    unless module_importable? "PyQt4.Qsci"
      s += <<~EOS
        QScintilla Python module is needed by QGIS during run-time.
        Ensure `qscintilla2` formula is linked.

      EOS
    end

    s += <<~EOS
      If you have built GRASS 6.4.x or 7.0.x support for the Processing plugin set
      the following in QGIS:
        Processing->Options: Providers->GRASS commands->GRASS folder to:
           #{HOMEBREW_PREFIX}/opt/grass-64/grass-base
        Processing->Options: Providers->GRASS GIS 7 commands->GRASS 7 folder to:
           #{HOMEBREW_PREFIX}/opt/grass-70/grass-base

    EOS

    s
  end

  private

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
    Pathname.new(`#{python_exec} -c "from distutils import sysconfig; print(sysconfig.get_python_inc())"`.strip)
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
