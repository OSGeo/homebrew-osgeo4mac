require File.expand_path("../../Requirements/qgis_requirements",
                         Pathname.new(__FILE__).realpath)

class Qgis2 < Formula
  desc "Open Source Geographic Information System"
  homepage "https://www.qgis.org"

  # revision 1
  head "https://github.com/qgis/QGIS.git", :branch => "release-2_18"

  stable do
    url "https://github.com/qgis/QGIS/archive/final-2_18_13.tar.gz"
    sha256 "de26fb9ee5394414f9410543bc7f7731d071ce3d8310ef40abb497a080a9619b"

    # patches that represent all backports to release-2_18 branch, since release tag
    # see: https://github.com/qgis/QGIS/commits/release-2_18
    # patch do
    #   # thru commit ?, minus windows-formatted patches
    #   # (just commit https://github.com/qgis/QGIS/commit/5e1e441 for now)
    #   url ""
    #   sha256 ""
    # end
  end

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    sha256 "cb76323d18b524d9f4ffec5cb380daf0ca0b2d20b1068aa03320881d11f6a5d0" => :sierra
  end

  def pour_bottle?
    brewed_python?
  end

  option "with-isolation", "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "with-gdal-1", "Build with GDAL/OGR v1.x instead of v2.x"
  option "with-globe", "Build with Globe plugin, based upon osgEarth"
  option "with-grass", "Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)"
  option "with-grass6", "Build extra GRASS 6 for Processing plugin"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-orfeo5", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga-gis", "Build extra Saga GIS for Processing plugin"
  # option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"
  option "with-qspatialite", "Build QSpatialite Qt database driver"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"

  # depends on UnlinkedQGIS2

  # core qgis
  depends_on "cmake" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => :build
  end
  depends_on (build.with?("isolation") || MacOS.version < :lion) ? "python" : :python
  depends_on "qt-4"
  depends_on "sip-qt4"
  depends_on "pyqt-qt4"
  depends_on "qca-qt4"
  depends_on "qscintilla2-qt4"
  depends_on "qwt-qt4"
  depends_on "qwtpolar-qt4"
  depends_on "qjson-qt4"
  depends_on "gsl"
  depends_on "sqlite" # keg_only
  depends_on "expat" # keg_only
  depends_on "proj"
  depends_on "spatialindex"
  depends_on "fcgi" if build.with? "server"
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on "postgresql" => :recommended

  # core providers
  if build.with? "gdal-1"
    depends_on "gdal"
  else
    depends_on "gdal2"
    depends_on "gdal2-python"
  end
  depends_on "oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with?("grass") || (HOMEBREW_PREFIX/"opt/grass7").exist?
    depends_on "grass7"
    depends_on "gettext"
  end

  if build.with? "globe"
    # this is pretty borked with OS X >= 10.10+
    # depends on "open-scene-graph" => ["with-qt"]
    depends_on "open-scene-graph"
    depends_on "homebrew/science/osgearth"
  end
  depends_on "gpsbabel-qt4" => :optional
  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)
  depends_on "pyspatialite" # for DB Manager
  # depends on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `grass` above
  depends_on "grass6" => :optional
  depends_on "orfeo5" => :optional
  depends_on "r" => :optional
  depends_on "saga-gis-lts" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  resource "pyqgis-startup" do
    url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
    sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
    version "2.14.0"
  end

  def install
    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.

    # Install custom widgets Designer plugin to local qt-4 plugins prefix
    inreplace "src/customwidgets/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/designer", lib_qt4/"plugins/designer".to_s

    # Fix custom widgets designer module install path
    # TODO: add for QtWebkit bindings and PYQT5_MOD_DIR in qgis-dev
    inreplace "CMakeLists.txt",
              "${PYQT4_MOD_DIR}", lib_qt4/"python2.7/site-packages/PyQt4".to_s

    # Install qspatialite db plugin to local qt-4 plugins prefix
    if build.with? "qspatialite"
      inreplace "src/providers/spatialite/qspatialite/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib_qt4/"plugins/sqldrivers".to_s
    end

    qwt_fw = Formula["qwt-qt4"].opt_lib/"qwt.framework"
    qwtpolar_fw = Formula["qwtpolar-qt4"].opt_lib/"qwtpolar.framework"
    qsci_opt = Formula["qscintilla2-qt4"].opt_prefix
    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override
    args += %W[
      -DBISON_EXECUTABLE=#{Formula["bison"].opt_bin}/bison
      -DFLEX_EXECUTABLE=#{Formula["flex"].opt_bin}/flex
      -DENABLE_TESTS=FALSE
      -DENABLE_MODELTEST=FALSE
      -DSUPPRESS_QT_WARNINGS=TRUE
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQSCINTILLA_INCLUDE_DIR=#{qsci_opt}/libexec/include
      -DQSCINTILLA_LIBRARY=#{qsci_opt}/libexec/lib/libqscintilla2.dylib
      -DQSCI_SIP_DIR=#{qsci_opt}/share/sip-qt4
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_INSTALL_DEV=FALSE
      -DWITH_QSCIAPI=FALSE
      -DWITH_STAGED_PLUGINS=TRUE
      -DWITH_GRASS=FALSE
      -DWITH_CUSTOM_WIDGETS=TRUE
    ]

    if build.without? "gdal-1"
      args << "-DGDAL_LIBRARY=#{Formula["gdal2"].opt_lib}/libgdal.dylib"
      args << "-DGDAL_INCLUDE_DIR=#{Formula["gdal2"].opt_include}"
      # These specific includes help ensure any gdal v1 includes are not
      # accidentally pulled from /usr/local/include
      # In CMakeLists.txt throughout QGIS source tree these includes may come
      # before opt/gdal2/include; 'fixing' many CMakeLists.txt may be unwise
      args << "-DGEOS_INCLUDE_DIR=#{Formula["geos"].opt_include}"
      args << "-DGSL_INCLUDE_DIR=#{Formula["gsl"].opt_include}"
      args << "-DPROJ_INCLUDE_DIR=#{Formula["proj"].opt_include}"
      args << "-DQCA_INCLUDE_DIR=#{Formula["qca-qt4"].opt_lib}/qca.framework/Headers"
      args << "-DSPATIALINDEX_INCLUDE_DIR=#{Formula["spatialindex"].opt_include}/spatialindex"
      args << "-DSPATIALITE_INCLUDE_DIR=#{Formula["libspatialite"].opt_include}"
      args << "-DSQLITE3_INCLUDE_DIR=#{Formula["sqlite"].opt_include}"
    end

    args << "-DPYTHON_EXECUTABLE='#{`python2 -c "import sys; print(sys.executable)"`.chomp}'"
    args << "-DPYTHON_CUSTOM_FRAMEWORK='#{`python2 -c "import sys; print(sys.prefix)"`.chomp}'"

    # find git revision for HEAD build
    if build.head? && File.exist?("#{cached_download}/.git/index")
      args << "-DGITCOMMAND=#{Formula["git"].opt_bin}/git"
      args << "-DGIT_MARKER=#{cached_download}/.git/index"
    end

    args << "-DWITH_SERVER=#{build.with?("server") ? "TRUE" : "FALSE"}"
    if build.with? "server"
      fcgi_opt = Formula["fcgi"].opt_prefix
      args << "-DFCGI_INCLUDE_DIR=#{fcgi_opt}/include"
      args << "-DFCGI_LIBRARY=#{fcgi_opt}/lib/libfcgi.dylib"
    end

    args << "-DPOSTGRES_CONFIG=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"

    args << "-DWITH_GRASS7=#{(build.with?("grass") || brewed_grass7?) ? "TRUE" : "FALSE"}"
    if build.with?("grass") || brewed_grass7?
      # this is to build the GRASS Plugin, not for Processing plugin support
      grass7 = Formula["grass7"]
      args << "-DGRASS_PREFIX7='#{grass7.opt_prefix}/grass-base'"
      # Keep superenv from stripping (use Cellar prefix)
      ENV.append "CXXFLAGS", "-isystem #{grass7.prefix.resolved_path}/grass-base/include"
      # So that `libintl.h` can be found (use Cellar prefix)
      ENV.append "CXXFLAGS", "-isystem #{Formula["gettext"].include.resolved_path}"
    end

    args << "-DWITH_GLOBE=#{build.with?("globe") ? "TRUE" : "FALSE"}"
    if build.with? "globe"
      osg = Formula["open-scene-graph"]
      opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
      # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    args << "-DWITH_ORACLE=#{build.with?("oracle") ? "TRUE" : "FALSE"}"
    if build.with? "oracle"
      oracle_opt = Formula["oracle-client-sdk"].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/include/oci"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    args << "-DWITH_QSPATIALITE=#{build.with?("qspatialite") ? "TRUE" : "FALSE"}"

    args << "-DWITH_APIDOC=#{build.with?("api-docs") ? "TRUE" : "FALSE"}"

    # Avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append "CXXFLAGS", "-F#{Formula["qt-4"].opt_lib}"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = brewed_python_framework.to_s if brewed_python?

    # handle custom site-packages for qt-4 keg-only modules and packages
    ENV["PYTHONPATH"] = python_qt4_site_packages

    # handle some compiler warnings
    ENV["CXX_EXTRA_FLAGS"] = "-Wno-unused-private-field -Wno-deprecated-register"
    if ENV.compiler == :clang && (MacOS::Xcode.version >= "7.0" || MacOS::CLT.version >= "7.0")
      ENV.append "CXX_EXTRA_FLAGS", "-Wno-inconsistent-missing-override"
    end

    mkdir "build" do
      # bbedit = "/usr/local/bin/bbedit"
      # cmake_config = Pathname("#{Dir.pwd}/#{name}_cmake-config.txt")
      # cmake_config.write ["cmake ..", *args].join(" \\\n")
      # system bbedit, cmake_config.to_s
      # raise
      system "cmake", "..", *args
      # system bbedit, "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
    end

    # Fixup some errant lib linking
    # TODO: fix upstream in CMake
    dy_libs = [lib_qt4/"plugins/designer/libqgis_customwidgets.dylib"]
    dy_libs << lib_qt4/"plugins/sqldrivers/libqsqlspatialite.dylib" if build.with? "qspatialite"
    dy_libs.each do |dy_lib|
      MachO::Tools.dylibs(dy_lib.to_s).each do |i_n|
        %w[core gui].each do |f_n|
          sufx = i_n[/(qgis_#{f_n}\.framework.*)/, 1]
          next if sufx.nil?
          i_n_to = "#{opt_prefix}/QGIS.app/Contents/Frameworks/#{sufx}"
          puts "Changing install name #{i_n} to #{i_n_to} in #{dy_lib}" if ARGV.debug?
          dy_lib.ensure_writable do
            MachO::Tools.change_install_name(dy_lib.to_s, i_n.to_s, i_n_to, :strict => false)
          end
        end
      end
    end

    # Update .app's bundle identifier, so Kyngchaos.com installer doesn't get confused
    inreplace prefix/"QGIS.app/Contents/Info.plist",
              "org.qgis.qgis2", "org.qgis.qgis2-hb#{build.head? ? "-dev" : ""}"

    py_lib = libexec/"python2.7/site-packages"
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
    qgis_bin = bin/name.to_s
    touch qgis_bin.to_s # so it will be linked into HOMEBREW_PREFIX
    qgis_bin.chmod 0755
    post_install
  end

  def post_install
    # configure environment variables for .app and launching binary directly.
    # having this in `post_intsall` allows it to be individually run *after* installation with:
    #    `brew postinstall -v <formula-name>`

    app = prefix/"QGIS.app"
    tab = Tab.for_formula(self)
    opts = tab.used_options
    # bottle_poured = tab.poured_from_bottle

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = python_site_packages.to_s
    pths = %w[/usr/bin /bin /usr/sbin /sbin /opt/X11/bin /usr/X11/bin]

    unless opts.include?("with-isolation")
      pths = ORIGINAL_PATHS.dup
      pyenv = ENV["PYTHONPATH"]
      if pyenv
        pypth = pyenv.include?(pypth) ? pyenv : pypth + pthsep + pyenv
      end
    end

    unless pths.include?(HOMEBREW_PREFIX/"bin")
      pths = pths.insert(0, HOMEBREW_PREFIX/"bin")
    end

    # set qt-4's then install's libexec/python2.7/site-packages first, so app will work if unlinked
    pypths = %W[#{python_qt4_site_packages} #{opt_libexec}/python2.7/site-packages #{pypth}]

    unless opts.include?("with-gdal-1")
      pths.insert(0, Formula["gdal2"].opt_bin.to_s)
      pths.insert(0, Formula["gdal2-python"].opt_bin.to_s)
      pypths.insert(0, "#{Formula["gdal2-python"].opt_lib}/python2.7/site-packages")
    end

    # prepend qt-4 based utils to PATH (reverse order)
    pths.insert(0, Formula["qca-qt4"].opt_bin.to_s)
    pths.insert(0, Formula["pyqt-qt4"].opt_bin.to_s)
    pths.insert(0, "#{Formula["sip-qt4"].opt_libexec}/bin")
    pths.insert(0, Formula["qt-4"].opt_bin.to_s)

    if opts.include?("with-gpsbabel-qt4")
      pths.insert(0, Formula["gpsbabel-qt4"].opt_bin.to_s)
    end

    envars = {
      :PATH => pths.join(pthsep),
      :PYTHONPATH => pypths.join(pthsep),
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins",
    }
    envars[:GDAL_DATA] = "#{Formula[opts.include?("with-gdal-1") ? "gdal": "gdal2"].opt_share}/gdal"

    proc_algs = "Contents/Resources/python/plugins/processing/algs"
    if opts.include?("with-grass") || brewed_grass7?
      grass7 = Formula["grass7"]
      # for core integration plugin support
      envars[:GRASS_PREFIX] = "#{grass7.opt_prefix}/grass-base"
      begin
        inreplace app/"#{proc_algs}/grass7/Grass7Utils.py",
                  "/Applications/GRASS-7.0.app/Contents/MacOS",
                  "#{grass7.opt_prefix}/grass-base"
        puts "GRASS 7 GrassUtils.py has been updated"
      rescue Utils::InreplaceError
        puts "GRASS 7 GrassUtils.py already updated"
      end
    end

    if opts.include?("with-grass6") || brewed_grass6?
      grass6 = Formula["grass6"]
      begin
        inreplace app/"#{proc_algs}/grass/GrassUtils.py",
                  "/Applications/GRASS-6.4.app/Contents/MacOS",
                  "#{grass6.opt_prefix}/grass-base"
        puts "GRASS 6 GrassUtils.py has been updated"
      rescue Utils::InreplaceError
        puts "GRASS 6 GrassUtils.py already updated"
      end
    end

    if opts.include?("with-orfeo5") || brewed_orfeo5?
      orfeo5 = Formula["orfeo5"]
      begin
        inreplace app/"#{proc_algs}/otb/OTBUtils.py" do |s|
          # default geoid path
          # try to replace first, so it fails (if already done) before global replaces
          s.sub! "OTB_GEOID_FILE) or ''", "OTB_GEOID_FILE) or '#{orfeo5.opt_libexec}/default_geoid/egm96.grd'"
          # default bin and lib path
          s.gsub! "/usr/local/bin", orfeo5.opt_bin.to_s
          s.gsub! "/usr/local/lib", orfeo5.opt_lib.to_s
        end
        puts "ORFEO 5 OTBUtils.py has been updated"
      rescue Utils::InreplaceError
        puts "ORFEO 5 OTBUtils.py already updated"
      end
    end

    unless opts.include?("without-globe")
      osg = Formula["open-scene-graph"]
      envars[:OSG_LIBRARY_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    if opts.include?("with-isolation")
      envars[:DYLD_FRAMEWORK_PATH] = "#{HOMEBREW_PREFIX}/Frameworks:/System/Library/Frameworks"
      versioned = %W[
        #{Formula["sqlite"].opt_lib}
        #{Formula["expat"].opt_lib}
        #{Formula["libxml2"].opt_lib}
        #{HOMEBREW_PREFIX}/lib
      ]
      envars[:DYLD_VERSIONED_LIBRARY_PATH] = versioned.join(pthsep)
    end
    if opts.include?("with-isolation") || File.exist?("/Library/Frameworks/GDAL.framework")
      envars[:PYQGIS_STARTUP] = opt_libexec/"pyqgis_startup.py"
    end

    # envars.each { |key, value| puts "#{key.to_s}=#{value}" }
    # exit

    # add env vars to QGIS.app's Info.plist, in LSEnvironment section
    plst = app/"Contents/Info.plist"
    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: may not be what you want, if .app already has LSEnvironment settings
    dflt = `defaults read-type \"#{plst}\" LSEnvironment 2> /dev/null`
    `defaults delete \"#{plst}\" LSEnvironment` if dflt
    kv = "{ "
    envars.each { |key, value| kv += "'#{key}' = '#{value}'; " }
    kv += "}"
    `defaults write \"#{plst}\" LSEnvironment \"#{kv}\"`
    # add ability to toggle high resolution in Get Info dialog for app
    hrc = `defaults read-type \"#{plst}\" NSHighResolutionCapable 2> /dev/null`
    `defaults delete \"#{plst}\" NSHighResolutionCapable` if hrc
    `defaults write \"#{plst}\" NSHighResolutionCapable \"False\"`
    # leave the plist readable; convert from binary to XML format
    `plutil -convert xml1 -- \"#{plst}\"`
    # make sure plist is readble by all users
    plst.chmod 0644
    # update modification date on app bundle, or changes won't take effect
    touch app.to_s

    # add env vars to launch script for QGIS app's binary
    qgis_bin = bin/name.to_s
    rm_f qgis_bin if File.exist?(qgis_bin) # install generates empty file
    bin_cmds = %W[#!/bin/sh\n]
    # setup shell-prepended env vars (may result in duplication of paths)
    unless pths.include? HOMEBREW_PREFIX/"bin"
      pths.insert(0, HOMEBREW_PREFIX/"bin")
    end
    # even though this should be affected by with-isolation, allow local env override
    pths << "$PATH"
    pypths << "$PYTHONPATH"
    envars[:PATH] = pths.join(pthsep)
    envars[:PYTHONPATH] = pypths.join(pthsep)
    envars.each { |key, value| bin_cmds << "export #{key}=#{value}" }
    bin_cmds << opt_prefix/"QGIS.app/Contents/MacOS/QGIS \"$@\""
    qgis_bin.write(bin_cmds.join("\n"))
    qgis_bin.chmod 0755
  end

  def caveats
    s = <<-EOS.undent
      Bottles support only Homebrew's Python

      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in QGIS.app:
        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into /Applications or ~/Applications:
        brew linkapps [--local]

      To directly run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper
      script pre-defined with Homebrew prefix environment variables:
        #{opt_bin}/#{name}

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app
            bundle they are not.

      For standalone Python development, set the following environment variable:
        export PYTHONPATH=#{libexec/"python2.7/site-packages"}:#{python_qt4_site_packages}:#{python_site_packages}:$PYTHONPATH

    EOS

    if build.with? "isolation"
      s += <<-EOS.undent
        QGIS built with isolation enabled. This allows it to coexist with other
        types of installations of QGIS on your Mac. However, on versions >= 2.0.1,
        this also means Python modules installed in the *system* Python will NOT
        be available to Python processes within QGIS.app.

      EOS
    end

    # check for required run-time Python module dependencies
    # TODO: add "pyspatialite" when PyPi package supports spatialite 4.x
    xm = []
    %w[psycopg2 matplotlib pyparsing requests future jinja2 pygments].each do |m|
      xm << m unless module_importable? m
    end
    unless xm.empty?
      s += <<-EOS.undent
        #{Tty.red}
        The following Python modules are needed by QGIS during run-time:

            #{xm.join(", ")}

        You can install manually, via installer package or with `pip` (if availble):

            pip install <module>  OR  pip-2.7 install <module>
        #{Tty.red}
        #{Tty.reset}
      EOS
    end
    # TODO: remove this when libqscintilla.dylib becomes core build dependency?
    unless module_importable? "PyQt4.Qsci"
      s += <<-EOS.undent
        QScintilla Python module is needed by QGIS during run-time.
        Ensure `qscintilla2-qt4` formula is linked.

      EOS
    end

    s += <<-EOS.undent
      If you have built GRASS 6.4.x or 7.0.x support for the Processing plugin set
      the following in QGIS:
        Processing->Options: Providers->GRASS commands->GRASS folder to:
           #{HOMEBREW_PREFIX}/opt/grass6/grass-base
        Processing->Options: Providers->GRASS GIS 7 commands->GRASS 7 folder to:
           #{HOMEBREW_PREFIX}/opt/grass7/grass-base

    EOS

    s
  end

  test do
    output = `#{bin}/#{name.to_s} --help 2>&1` # why does help go to stderr?
    assert_match /^QGIS is a user friendly/, output
  end

  private

  def brewed_grass7?
    Formula["grass7"].opt_prefix.exist?
  end

  def brewed_grass6?
    Formula["grass6"].opt_prefix.exist?
  end

  def brewed_orfeo5?
    Formula["orfeo5"].opt_prefix.exist?
  end

  def brewed_python_framework
    HOMEBREW_PREFIX/"Frameworks/Python.framework/Versions/2.7"
  end

  def brewed_python_framework?
    brewed_python_framework.exist?
  end

  def brewed_python?
    Formula["python"].linked_keg.exist? && brewed_python_framework?
  end

  def python_exec
    if brewed_python?
      brewed_python_framework/"bin/python2"
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

  def hb_lib_qt4
    HOMEBREW_PREFIX/"lib/qt-4"
  end

  def python_qt4_site_packages
    hb_lib_qt4/"python2.7/site-packages"
  end

  def lib_qt4
    lib/"qt-4"
  end

  def opt_lib_qt4
    opt_lib/"qt-4"
  end

  def module_importable?(mod)
    quiet_system python_exec, "-c", "import sys;sys.path.insert(1, '#{python_qt4_site_packages}'); import #{mod}"
  end
end
