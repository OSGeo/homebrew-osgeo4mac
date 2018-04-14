class Qgis3UnlinkedFormulae < Requirement
  fatal true
  satisfy(:build_env => false) { !qt4_linked && !pyqt4_linked && !txt2tags_linked }

  def qt4_linked
    (Formula["qt"].linked_keg/"lib/QtCore.framework/Versions/4").exist?
  rescue
    return false
  end

  def pyqt4_linked
    (Formula["pyqt"].linked_keg/"lib/python2.7/site-packages/PyQt").exist?
  rescue
    return false
  end

  def txt2tags_linked
    Formula["txt2tags"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "Compilation can fail if these formulae are installed and linked:\n\n"

    s += "Unlink with `brew unlink qt` or remove with `brew uninstall qt`\n" if qt4_linked
    s += "Unlink with `brew unlink pyqt` or remove with `brew uninstall pyqt`\n" if pyqt4_linked
    s += "Unlink with `brew unlink txt2tags` or remove with `brew uninstall txt2tags`\n" if txt2tags_linked
    s
  end
end

class Qgis3 < Formula
  # support venv
  include Language::Python::Virtualenv

  desc "User friendly open source Geographic Information System"
  homepage "https://www.qgis.org"

  url "https://github.com/qgis/QGIS.git", :tag => "final-3_0_1"
  version "3.0.1"

  option "without-ninja", "Disable use of ninja CMake generator"
  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-qt5-webkit", "Build without webkit based functionality"
  option "without-pyqt5-webkit", "Build without webkit python bindings"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "with-globe", "Build with Globe plugin, based upon osgEarth"
  option "with-grass", "Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-orfeo5", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga-gis-lts", "Build extra Saga GIS for Processing plugin"
  # option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"
  option "with-qspatialite", "Build QSpatialite Qt database driver"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"
  option "with-3d", "Build with 3D Map View panel"

  depends_on Qgis3UnlinkedFormulae

  # core qgis
  depends_on "cmake" => :build
  depends_on "ninja" => [:build, :recommended]
  depends_on "bison" => :build
  depends_on "flex" => :build
  if build.with? "api-docs"
    depends_on "graphviz"
    depends_on "doxygen"
  end

  depends_on "python"

  depends_on "qt" # keg_only
  depends_on "osgeo/osgeo4mac/qt5-webkit" => :recommended # keg_only
  depends_on "sip"
  depends_on "pyqt"
  depends_on "osgeo/osgeo4mac/pyqt5-webkit" => :recommended
  depends_on "qca"
  depends_on "qtkeychain"
  depends_on "qscintilla2"
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
  depends_on "libzip"
  depends_on "gdal"

  # needed for PKI authentication methods that require PKCS#8->PKCS#1 conversion
  depends_on "libtasn1"

  # core providers
  depends_on "osgeo/osgeo4mac/oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with?("grass") || (HOMEBREW_PREFIX/"opt/grass7").exist?
    depends_on "osgeo/osgeo4mac/grass7"
    depends_on "gettext" # keg_only
  end

  # Not until osgearth is Qt5-ready
  # if build.with? "globe"
  #   # this is pretty borked with OS X >= 10.10+
  #   depends on "open-scene-graph"
  #   depends on "homebrew/science/osgearth"
  # end

  depends_on "gpsbabel" => :optional
  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)

  # TODO: what to do for Py3 and pyspatialite?
  # depends on "pyspatialite" # for DB Manager
  # depends on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `grass` above
  depends_on "osgeo/osgeo4mac/orfeo5" => :optional
  depends_on "r" => :optional
  depends_on "osgeo/osgeo4mac/saga-gis-lts" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  # TODO: add one for Py3
  #       (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)
  # resource "pyqgis-startup" do
  #   url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  #   sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  #   version "2.14.0"
  # end

  needs :cxx11

  # for venv
  resource "future" do
    url "https://files.pythonhosted.org/packages/00/2b/8d082ddfed935f3608cc61140df6dcbf0edea1bc3ab52fb6c29ae3e81e85/future-0.16.0.tar.gz"
    sha256 "e39ced1ab767b5936646cedba8bcce582398233d6a627067d4c6a454c90cfedb"
  end
  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/74/83/51580322ed0e82cba7ad8e0af590b8fb2cf11bd5aaa1ed872661bd36f462/psycopg2-2.7.4.tar.gz"
    sha256 "8bf51191d60f6987482ef0cfe8511bbf4877a5aa7f313d7b488b53189cf26209"
  end
  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/c5/39/4da7c2dbc4f023fba5fb2325febcadf0d0ce0efdc8bd12083a0f65d20653/python-dateutil-2.7.2.tar.gz"
    sha256 "9d8074be4c993fbe4947878ce593052f71dac82932a677d49194d8ce9778002e"
  end
  resource "httplib2" do
    url "https://files.pythonhosted.org/packages/fd/ce/aa4a385e3e9fd351737fd2b07edaa56e7a730448465aceda6b35086a0d9b/httplib2-0.11.3.tar.gz"
    sha256 "e71daed9a0e6373642db61166fa70beecc9bf04383477f84671348c02a04cbdf"
  end
  resource "pytz" do
    url "https://files.pythonhosted.org/packages/10/76/52efda4ef98e7544321fd8d5d512e11739c1df18b0649551aeccfb1c8376/pytz-2018.4.tar.gz"
    sha256 "c06425302f2cf668f1bba7a0a03f3c1d34d4ebeef2c72003da308b3947c7f749"
  end
  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end
  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end
  resource "nose2" do
    url "https://files.pythonhosted.org/packages/93/46/a389a65237d0520bb4a98fc174fdf6568ad9dcc79b9c1d1f30afc6776031/nose2-0.7.4.tar.gz"
    sha256 "954a62cfb2d2ac06dad32995cbc822bf00cc11e20d543963515932fd4eff33fa"
  end
  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/71/2a/2e4e77803a8bd6408a2903340ac498cb0a2181811af7c9ec92cb70b0308a/Pygments-2.2.0.tar.gz"
    sha256 "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"
  end
  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"
    sha256 "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"
  end
  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"
    sha256 "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"
  end
  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"
    sha256 "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"
  end
  resource "requests" do
    url "https://files.pythonhosted.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz"
    sha256 "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e"
  end
  resource "OWSLib" do
    url "https://files.pythonhosted.org/packages/ac/71/ff2fbfa64fca17069ce30fac324533aa686c5cb64e6b5f522faed558848f/OWSLib-0.16.0.tar.gz"
    sha256 "ec95a5e93c145a5d84b0074b9ea27570943486552a669151140debf08a100554"
  end
  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/ec/ed/46b835da53b7ed05bd4c6cae293f13ec26e877d2e490a53a709915a9dcb7/matplotlib-2.2.2.tar.gz"
    sha256 "4dc7ef528aad21f22be85e95725234c5178c0f938e2228ca76640e5e84d8cde8"
  end
  resource "GDAL" do
    url "https://files.pythonhosted.org/packages/4d/74/15958684bdec900d72c13fdc7e455d75d36437018e238f8c8fc7dd5aad37/GDAL-2.2.4.tar.gz"
    sha256 "7cc793b62f375612415ab7c10d10d45f727d42c39bf6ea51eb4b82f0c996e1e6"
  end


  def install
    ENV.cxx11

    # when gdal2-python.rb loaded, PYTHONPATH gets set to 2.7 site-packages...
    #   clear it before calling any local python3 functions
    ENV["PYTHONPATH"] = nil
    if ARGV.debug?
      puts "python_exec: #{python_exec}"
      puts "py_ver: #{py_ver}"
      puts "brewed_python?: #{brewed_python?}"
      puts "python_site_packages: #{python_site_packages}"
      puts "python_prefix: #{python_prefix}"
      puts "qgis_python_packages: #{qgis_python_packages}"
      puts "gdal_opt_bin: #{gdal_opt_bin}"
    end



    # Vendor required python3 pkgs if they are missing
    # TODO: this should really be a requirements.txt in src tree
    py_req = %w[
      future
      psycopg2
      python-dateutil
      httplib2
      pytz
      six
      nose2
      Pygments
      Jinja2
      MarkupSafe
      PyYAML
      requests
      OWSLib
      Cycler
      matplotlib
      GDAL
    ].freeze

    orig_user_base = ENV["PYTHONUSERBASE"]
    ENV["PYTHONUSERBASE"] = libexec/"python"
    system HOMEBREW_PREFIX/"bin/pip3", "install", "--user", *py_req
    ENV["PYTHONUSERBASE"] = orig_user_base
    # venv test but fail at installing matplotlib
    #venv3 = virtualenv_create(libexec, "python3")
    #py_req.each do |r|
    #  venv3.pip_install resource(r)
    #end
    #venv.pip_install_and_link buildpath

    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.

    # Install custom widgets Designer plugin to local qt plugins prefix
    mkdir lib/"qt/plugins/designer"
    inreplace "src/customwidgets/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/designer", lib/"qt/plugins/designer".to_s

    # Fix custom widgets Designer module install path
    mkdir lib/"python#{py_ver}/site-packages/PyQt5"
    inreplace "CMakeLists.txt",
              "${PYQT5_MOD_DIR}", lib/"python#{py_ver}/site-packages/PyQt5".to_s

    # Install db plugins to local qt plugins prefix
    if build.with? "qspatialite"
      mkdir lib/"qt/plugins/sqldrivers"
      inreplace "src/providers/spatialite/qspatialite/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s
    end
    if build.with? "oracle"
      inreplace "src/providers/oracle/ocispatial/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s
    end

    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override

    cmake_prefixes = %w[
      qt5
      qt5-webkit
      qscintilla2
      qwt
      qwtpolar
      qca
      gdal
      gsl
      geos
      proj
      libspatialite
      spatialindex
      expat
      sqlite
      libzip
      flex
      bison
      fcgi
    ].freeze
    # Force CMake to search HB/opt paths first, so headers in HB/include are not found instead;
    # specifically, ensure any gdal v1 includes are not used
    args << "-DCMAKE_PREFIX_PATH=#{cmake_prefixes.map { |f| Formula[f.to_s].opt_prefix }.join(";")}"

    args += %w[
      -DENABLE_TESTS=FALSE
      -DENABLE_MODELTEST=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_INSTALL_DEV=FALSE
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DWITH_ASTYLE=FALSE
      -DWITH_QSCIAPI=TRUE
      -DWITH_STAGED_PLUGINS=TRUE
      -DWITH_GRASS=FALSE
      -DWITH_CUSTOM_WIDGETS=TRUE
    ]

    args << "-DWITH_QTWEBKIT=#{build.with?("qt5-webkit") ? "TRUE" : "FALSE"}"

    # Prefer opt_prefix for CMake modules that find versioned prefix by default
    # This keeps non-critical dependency upgrades from breaking QGIS linking
    args << "-DGDAL_LIBRARY=#{Formula["gdal"].opt_lib}/libgdal.dylib"
    args << "-DGEOS_LIBRARY=#{Formula["geos"].opt_lib}/libgeos_c.dylib"
    args << "-DGSL_CONFIG=#{Formula["gsl"].opt_bin}/gsl-config"
    args << "-DGSL_INCLUDE_DIR=#{Formula["gsl"].opt_include}"
    args << "-DGSL_LIBRARIES='-L#{Formula["gsl"].opt_lib} -lgsl -lgslcblas'"

    args << "-DWITH_SERVER=#{build.with?("server") ? "TRUE" : "FALSE"}"

    args << "-DPOSTGRES_CONFIG=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"

    args << "-DWITH_GRASS7=#{(build.with?("grass") || brewed_grass7?) ? "TRUE" : "FALSE"}"
    if build.with?("grass") || brewed_grass7?
      # this is to build the GRASS Plugin, not for Processing plugin support
      grass7 = Formula["grass7"]
      args << "-DGRASS_PREFIX7='#{grass7.opt_prefix}/grass-base'"
      # Keep superenv from stripping (use Cellar prefix)
      ENV.append "CXXFLAGS", "-isystem #{grass7.prefix.resolved_path}/grass-base/include"
      # So that `libintl.h` can be found (use Cellar prefix; should not be needed anymore with QGIS 2.99+)
      # ENV.append "CXXFLAGS", "-isystem #{Formula["gettext"].include.resolved_path}"
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

    args << "-DWITH_3D=#{build.with?("3d") ? "TRUE" : "FALSE"}"

    # nix clang tidy runs
    args << "-DCLANG_TIDY_EXE="

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = python_prefix

    # handle custom site-packages for keg-only modules and packages
    ENV.append_path "PYTHONPATH", python_site_packages
    ENV.append_path "PYTHONPATH", libexec/"python/lib/python/site-packages"


    # handle some compiler warnings
    # ENV["CXX_EXTRA_FLAGS"] = "-Wno-unused-private-field -Wno-deprecated-register"
    # if ENV.compiler == :clang && (MacOS::Xcode.version >= "7.0" || MacOS::CLT.version >= "7.0")
    #   ENV.append "CXX_EXTRA_FLAGS", "-Wno-inconsistent-missing-override"
    # end

    ENV.prepend_path "PATH", libexec/"python/bin"

    mkdir "build" do
      # editor = "/usr/local/bin/bbedit"
      # cmake_config = Pathname("#{Dir.pwd}/#{name}_cmake-config.txt")
      # cmake_config.write ["cmake ..", *args].join(" \\\n")
      # system editor, cmake_config.to_s
      # raise
      system "cmake", "-G", build.with?("ninja") ? "Ninja" : "Unix Makefiles", *args, ".."
      # system editor, "CMakeCache.txt"
      # raise
      system "cmake", "--build", ".", "--target", "all", "--", "-j", Hardware::CPU.cores
      system "cmake", "--build", ".", "--target", "install", "--", "-j", Hardware::CPU.cores
    end

    # Fixup some errant lib linking
    # TODO: fix upstream in CMake
    dy_libs = [lib/"qt/plugins/designer/libqgis_customwidgets.dylib"]
    dy_libs << lib/"qt/plugins/sqldrivers/libqsqlspatialite.dylib" if build.with? "qspatialite"
    dy_libs.each do |dy_lib|
      MachO::Tools.dylibs(dy_lib.to_s).each do |i_n|
        %w[core gui native].each do |f_n|
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

    # Update .app's bundle identifier, so other installers doesn't get confused
    inreplace prefix/"QGIS.app/Contents/Info.plist",
              "org.qgis.qgis3", "org.qgis.qgis3-homebrew"

    py_lib = lib/"python#{py_ver}/site-packages"
    py_lib.mkpath
    ln_s "../../../QGIS.app/Contents/Resources/python/qgis", py_lib/"qgis"

    ln_s "QGIS.app/Contents/MacOS/fcgi-bin", prefix/"fcgi-bin" if build.with? "server"

    doc.mkpath
    mv prefix/"QGIS.app/Contents/Resources/doc/api", doc/"api" if build.with? "api-docs"
    ln_s "../../../QGIS.app/Contents/Resources/doc", doc/"doc"

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    # TODO: for Py3
    # (libexec/"python").install resource("pyqgis-startup")

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

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = python_site_packages.to_s
    pths = %w[
      /usr/bin
      /bin
      /usr/sbin
      /sbin
      /opt/X11/bin
      /usr/X11/bin
      #{opt_libexec}/python/bin
    ]

    # unless opts.include?("with-isolation")
    #   pths = ORIGINAL_PATHS.dup
    #   pyenv = ENV["PYTHONPATH"]
    #   if pyenv
    #     pypth = pyenv.include?(pypth) ? pyenv : pypth + pthsep + pyenv
    #   end
    # end

    unless pths.include?(HOMEBREW_PREFIX/"bin")
      pths = pths.insert(0, HOMEBREW_PREFIX/"bin")
    end

    # set install's lib/python#{py_ver}/site-packages first, so app will work if unlinked
    pypths = %W[
      #{opt_lib}/python#{py_ver}/site-packages
      #{opt_libexec}/python/lib/python/site-packages
      #{pypth}
    ]
    # for venv test
    #site_packages = "lib/python#{version}/site-packages"
    #pypths << "import site; site.addsitedir('#{libexec/site_packages}')\n"

    pths.insert(0, gdal_opt_bin)

    if opts.include?("with-gpsbabel")
      pths.insert(0, Formula["gpsbabel"].opt_bin.to_s)
    end

    envars = {
      :PATH => pths.join(pthsep),
      :PYTHONPATH => pypths.join(pthsep),
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins",
      :GDAL_DATA => "#{Formula["gdal"].opt_share}/gdal",
    }

    # handle multiple Qt plugins directories
    qtplgpths = %W[
      #{Formula["qt"].opt_prefix}/plugins
      #{HOMEBREW_PREFIX}/lib/qt/plugins
    ]
    envars[:QT_PLUGIN_PATH] = qtplgpths.join(pthsep)

    proc_algs = "Contents/Resources/python/plugins/processing/algs"
    if opts.include?("with-grass") || brewed_grass7?
      grass7 = Formula["grass7"]
      # for core integration plugin support
      envars[:GRASS_PREFIX] = "#{grass7.opt_prefix}/grass-base"
      begin
        inreplace app/"#{proc_algs}/grass7/Grass7Utils.py",
                  "'/Applications/GRASS-7.{}.app/Contents/MacOS'.format(version)",
                  "'#{grass7.opt_prefix}/grass-base'"
        puts "GRASS 7 GrassUtils.py has been updated"
      rescue Utils::InreplaceError
        puts "GRASS 7 GrassUtils.py already updated"
      end
    end

    unless opts.include?("without-globe")
      osg = Formula["open-scene-graph"]
      envars[:OSG_LIBRARY_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    # TODO: add for Py3
    # if opts.include?("with-isolation") || File.exist?("/Library/Frameworks/GDAL.framework")
    #   envars[:PYQGIS_STARTUP] = opt_libexec/"python/pyqgis_startup.py"
    # end

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
    `defaults write \"#{plst}\" NSHighResolutionCapable \"True\"`
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
      Bottles support only Homebrew's Python3

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

      For standalone Python3 development, set the following environment variable:
        export PYTHONPATH=#{qgis_python_packages}:#{python_site_packages}:$PYTHONPATH

    EOS

    s += <<-EOS.undent
      If you have built GRASS 7 for the Processing plugin set the following in QGIS:
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

  def python_exec
    if brewed_python?
      Formula["python"].opt_bin/"python3"
    else
      py_exec = `which python`.strip
      raise if py_exec == ""
      py_exec
    end
  end

  def py_ver
    `#{python_exec} -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end

  def brewed_python?
    Formula["python"].linked_keg.exist?
  end

  def python_site_packages
    HOMEBREW_PREFIX/"lib/python#{py_ver}/site-packages"
  end

  def python_prefix
    `#{python_exec} -c 'import sys;print(sys.prefix)'`.strip
  end

  def qgis_python_packages
    opt_lib/"python#{py_ver}/site-packages".to_s
  end

  def gdal_opt_bin
    Formula["gdal"].opt_bin.to_s
  end

  def module_importable?(mod)
    `#{python_exec} -c 'import sys; import #{mod}'`.strip
  end
end
