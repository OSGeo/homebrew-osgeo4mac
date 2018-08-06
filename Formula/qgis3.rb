class UnlinkedQGIS3 < Requirement
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
  include Language::Python::Virtualenv
  desc "Open Source Geographic Information System"
  homepage "https://www.qgis.org"

  head "https://github.com/qgis/QGIS.git", :branch => "release-3_2"

  stable do
    url "https://github.com/qgis/QGIS/archive/final-3_2_1.tar.gz"
    sha256 "c1603f0afc13de6a0e0c10564c444ceaefebd5670bf41f6ea51c8eae1eac9b6c"
  end

  def pour_bottle?
    brewed_python?
  end

  option "without-ninja", "Disable use of ninja CMake generator"
  # option "without-qt5-webkit", "Build without webkit based functionality"
  # option "without-pyqt5-webkit", "Build without webkit python bindings"
  option "with-isolation", "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  # option "with-globe", "Build with Globe plugin, based upon osgEarth"
  option "with-grass", "Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  # option "with-orfeo5", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga-gis-lts", "Build extra Saga GIS for Processing plugin"
  # option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"
  option "with-qspatialite", "Build QSpatialite Qt database driver"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"
  option "with-3d", "Build with 3D Map View panel"

  depends_on UnlinkedQGIS3

  # core qgis
  depends_on "cmake" => :build
  depends_on "ninja" => [:build, :recommended]
  depends_on "fcgi" if build.with? "server"
  depends_on "gsl" => :build
  depends_on "sip" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "python"
  depends_on "qt"
  depends_on "pyqt"
  depends_on "pyqt5-webkit" => :recommended
  if build.with? "api-docs"
    depends_on "graphviz" => :build
    depends_on "doxygen" => :build
  end
  depends_on "qca"
  depends_on "qtkeychain"
  depends_on "qscintilla2"
  depends_on "qwt"
  depends_on "qwtpolar"
  depends_on "qjson"
  depends_on "sqlite" # keg_only
  depends_on "expat" # keg_only
  depends_on "proj"
  depends_on "spatialindex"
  depends_on "numpy"
  depends_on "brewsci/bio/matplotlib"
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on "postgresql" => :recommended
  depends_on "libzip" 
  depends_on "libtasn1"
  depends_on "hicolor-icon-theme"
  
  # core providers
  depends_on "gdal2-python"
    
  depends_on "oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with?("grass") || (HOMEBREW_PREFIX/"opt/grass7").exist?
    depends_on "grass7"
    depends_on "gettext"
  end

  # Not until osgearth is Qt5-ready
  # if build.with? "globe"
    # this is pretty borked with OS X >= 10.10+
    # depends_on "open-scene-graph"
    # depends_on "brewsci/science/osgearth"
  # end

  depends_on "gpsbabel" => :optional

  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)
  # TODO: what to do for Py3 and pyspatialite?
  # depends_on "pyspatialite" # for DB Manager
  # depends_on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `grass` above
  # depends_on "orfeo5" => :optional
  depends_on "r" => :optional
  depends_on "saga-gis-lts" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)
  resource "pyqgis-startup" do
    url "https://gist.githubusercontent.com/fjperini/96bb3654b4d8fd97c343345cd12b6cde/raw/785bea0f9f46f17a626ea31d3308393d0814d693/pyqgis_startup.py"
    sha256 "98483e262faa87fa82128527a2318e4b28937156eca0031503cc4ed273ef1fad"
    version "2.14.0"
  end 
    
  resource "certifi" do
    url "https://files.pythonhosted.org/packages/4d/9c/46e950a6f4d6b4be571ddcae21e7bc846fcbb88f1de3eff0f6dd0a6be55d/certifi-2018.4.16.tar.gz"
    sha256 "13e698f54293db9f89122b0581843a782ad0934a4fe0172d2a980ba77fc61bb7"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/65/c4/80f97e9c9628f3cac9b98bfca0402ede54e0563b56482e3e6e45c43c4935/idna-2.7.tar.gz"
    sha256 "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16"
  end

  resource "OWSLib" do
    url "https://files.pythonhosted.org/packages/ac/71/ff2fbfa64fca17069ce30fac324533aa686c5cb64e6b5f522faed558848f/OWSLib-0.16.0.tar.gz"
    sha256 "ec95a5e93c145a5d84b0074b9ea27570943486552a669151140debf08a100554"
  end
  
  # dependence for pyproj
  resource "cython" do
    url "https://files.pythonhosted.org/packages/d2/12/8ef44cede251b93322e8503fd6e1b25a0249fa498bebec191a5a06adbe51/Cython-0.28.4.tar.gz"
    sha256 "76ac2b08d3d956d77b574bb43cbf1d37bd58b9d50c04ba281303e695854ebc46"
  end

  # fix for Python3.7
  resource "pyproj" do
    url "https://github.com/jswhit/pyproj/archive/master.zip"
    sha256 "6611ca878ec6de71115f7705f7fcb3a900999ef1fa9616376c2de63edd3a7841"
    version "1.9.5.1"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/a0/b0/a4e3241d2dee665fea11baec21389aec6886655cd4db7647ddf96c3fad15/python-dateutil-2.7.3.tar.gz"
    sha256 "e27001de32f627c22380a688bcc43ce83504a7bc5da472209b4c70f02829f0b8"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/ca/a9/62f96decb1e309d6300ebe7eee9acfd7bccaeedd693794437005b9067b44/pytz-2018.5.tar.gz"
    sha256 "ffb9ef1de172603304d9d2819af6f5ece76f2e85ec10692a524dd876e72bf277"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/54/1f/782a5734931ddf2e1494e4cd615a51ff98e1879cbe9eecbdfeaf09aa75e9/requests-2.19.1.tar.gz"
    sha256 "ec22d826a36ed72a7358ff3fe56cbd4ba69dd7a6718ffd450ff0e9df7a47ce6a"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/3c/d2/dc5471622bd200db1cd9319e02e71bc655e9ea27b8e0ce65fc69de0dac15/urllib3-1.23.tar.gz"
    sha256 "a68ac5e15e76e7e5dd2b8f94007233e01effe3e50e8daddf69acfd81cb686baf"
  end

  resource "coverage" do
    url "https://files.pythonhosted.org/packages/35/fe/e7df7289d717426093c68d156e0fd9117c8f4872b6588e8a8928a0f68424/coverage-4.5.1.tar.gz"
    sha256 "56e448f051a201c5ebbaa86a5efd0ca90d327204d8b059ab25ad0f35fbfd79f1"
  end

  resource "funcsigs" do
    url "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"
    sha256 "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"
  end

  resource "future" do
    url "https://files.pythonhosted.org/packages/00/2b/8d082ddfed935f3608cc61140df6dcbf0edea1bc3ab52fb6c29ae3e81e85/future-0.16.0.tar.gz"
    sha256 "e39ced1ab767b5936646cedba8bcce582398233d6a627067d4c6a454c90cfedb"
  end

  resource "mock" do
    url "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"
    sha256 "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"
  end

  resource "nose2" do
    url "https://files.pythonhosted.org/packages/93/46/a389a65237d0520bb4a98fc174fdf6568ad9dcc79b9c1d1f30afc6776031/nose2-0.7.4.tar.gz"
    sha256 "954a62cfb2d2ac06dad32995cbc822bf00cc11e20d543963515932fd4eff33fa"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/3a/20/c81632328b1a4e1db65f45c0a1350a9c5341fd4bbb8ea66cdd98da56fe2e/numpy-1.15.0.zip"
    sha256 "f28e73cf18d37a413f7d5de35d024e6b98f14566a10d82100f9dc491a7d449f9"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/c8/c3/935b102539529ea9e6dcf3e8b899583095a018b09f29855ab754a2012513/pbr-4.2.0.tar.gz"
    sha256 "1b8be50d938c9bb75d0eaf7eda111eec1bf6dc88a62a6412e33bf077457e0f45"
  end

  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/b2/c1/7bf6c464e903ffc4f3f5907c389e5a4199666bf57f6cd6bf46c17912a1f9/psycopg2-2.7.5.tar.gz"
    sha256 "eccf962d41ca46e6326b97c8fe0a6687b58dfc1a5f6540ed071ff1474cea749e"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"
    sha256 "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"
    sha256 "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/71/2a/2e4e77803a8bd6408a2903340ac498cb0a2181811af7c9ec92cb70b0308a/Pygments-2.2.0.tar.gz"
    sha256 "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"
  end

  resource "httplib2" do
    url "https://files.pythonhosted.org/packages/fd/ce/aa4a385e3e9fd351737fd2b07edaa56e7a730448465aceda6b35086a0d9b/httplib2-0.11.3.tar.gz"
    sha256 "e71daed9a0e6373642db61166fa70beecc9bf04383477f84671348c02a04cbdf"
  end

  needs :cxx11

  def install
    ENV.cxx11

    # install python dependencies
    venv = virtualenv_create(libexec/'vendor', "python3")
    venv.pip_install resources.reject { |r| r.name == "pyqgis-startup" }
 
    # set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.

    # install custom widgets Designer plugin to local qt plugins prefix
    mkdir lib_qt/"plugins/designer"
    inreplace "src/customwidgets/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/designer", lib_qt/"plugins/designer".to_s

    # fix custom widgets Designer module install path
    mkdir lib_qt/"python#{py_ver}/site-packages/PyQt5"
    inreplace "CMakeLists.txt",
              "${PYQT5_MOD_DIR}", lib_qt/"python#{py_ver}/site-packages/PyQt5".to_s

    # install db plugins to local qt plugins prefix
    if build.with? "qspatialite"
      mkdir lib_qt/"plugins/sqldrivers"
      inreplace "src/providers/spatialite/qspatialite/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib_qt/"plugins/sqldrivers".to_s
    end
    if build.with? "oracle"
      inreplace "src/providers/oracle/ocispatial/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib_qt/"plugins/sqldrivers".to_s
    end

    qwt_fw = Formula["qwt"].opt_lib/"qwt.framework"
    qwtpolar_fw = Formula["qwtpolar"].opt_lib/"qwtpolar.framework"
    qca_fw = Formula["qca"].opt_lib/"qca-qt5.framework"
    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override
    args += %W[
      -DBISON_EXECUTABLE=#{Formula["bison"].opt_bin}/bison
      -DEXPAT_INCLUDE_DIR=#{Formula["expat"].opt_include}
      -DEXPAT_LIBRARY=#{Formula["expat"].opt_lib}/libexpat.dylib
      -DFLEX_EXECUTABLE=#{Formula["flex"].opt_bin}/flex
      -DPROJ_INCLUDE_DIR=#{Formula["proj"].opt_include}
      -DPROJ_LIBRARY=#{Formula["proj"].opt_lib}/libproj.dylib
      -DQCA_INCLUDE_DIR=#{qca_fw}/Headers
      -DQCA_LIBRARY=#{qca_fw}/qca-qt5
      -DQSCINTILLA_INCLUDE_DIR=#{Formula["qscintilla2"].opt_include}
      -DQSCINTILLA_LIBRARY=#{Formula["qscintilla2"].opt_lib}/libqscintilla2_qt5.dylib
      -DQSCI_SIP_DIR=#{Formula["qscintilla2"].opt_share}/sip
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DSPATIALINDEX_INCLUDE_DIR=#{Formula["spatialindex"].opt_include}/spatialindex
      -DSPATIALINDEX_LIBRARY=#{Formula["spatialindex"].opt_lib}/libspatialindex.dylib
      -DSQLITE3_INCLUDE_DIR=#{Formula["sqlite"].opt_include}
      -DSQLITE3_LIBRARY=#{Formula["sqlite"].opt_lib}/libsqlite3.dylib
      -DLIBZIP_INCLUDE_DIR=#{Formula["libzip"].opt_include}
      -DLIBZIP_LIBRARY=#{Formula["libzip"].opt_lib}/libzip.dylib
      -DSPATIALITE_INCLUDE_DIR=#{Formula["libspatialite"].opt_include}
      -DSPATIALITE_LIBRARY=#{Formula["libspatialite"].opt_lib}/libspatialite.dylib
      -DQTKEYCHAIN_INCLUDE_DIR=#{Formula["qtkeychain"].opt_include}/qt5keychain
      -DQTKEYCHAIN_LIBRARY=#{Formula["qtkeychain"].opt_lib}/libqt5keychain.dylib
      -DLIBTASN1_INCLUDE_DIR=#{Formula["libtasn1"].opt_include}
      -DLIBTASN1_LIBRARY=#{Formula["libtasn1"].opt_lib}/libtasn1.dylib

      -DPYRCC_PROGRAM=#{libexec}/vendor/bin/pyrcc5
      -DPYUIC_PROGRAM=#{libexec}/vendor/bin/pyuic5v

      -DWITH_QTWEBKIT=TRUE
      -DOPTIONAL_QTWEBKIT=#{Formula["qt-webkit"].opt_lib}/cmake/Qt5WebKitWidgets
      
      -DENABLE_TESTS=FALSE
      -DENABLE_MODELTEST=FALSE
      -DSUPPRESS_QT_WARNINGS=TRUE
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_INSTALL_DEV=FALSE
      -DWITH_QSCIAPI=TRUE
      -DWITH_STAGED_PLUGINS=TRUE
      -DWITH_CUSTOM_WIDGETS=TRUE
      -DWITH_ASTYLE=FALSE
    ]
        
    # python Configuration
    args << "-DPYTHON_EXECUTABLE='#{`python3 -c "import sys; print(sys.executable)"`.chomp}'"
    # args << "-DPYTHON_CUSTOM_FRAMEWORK='#{`python3 -c "import sys; print(sys.prefix)"`.chomp}'" # not used by the project
    # Disable future, because we've installed it in the virtualenv and will provide it at runtime.
    # args << "-DWITH_INTERNAL_FUTURE=FALSE" # not used by the project
    #args << "-DPYTHON_INCLUDE_PATH=#{Formula["python"].opt_include}"
    #args << "-DPYTHON_LIBRARY=/usr/local/Frameworks/Python.framework/Versions/#{py_ver}/Python"
    #args << "-DPYTHON_SITE_PACKAGES_DIR=/usr/local/lib/python#{py_ver}/site-packages"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = python_prefix if brewed_python?

    # handle custom site-packages for qt keg-only modules and packages
    ENV.prepend_path "PYTHONPATH", python_site_packages
    ENV.append_path "PYTHONPATH", python_qt_site_packages
    # ENV.append_path "PYTHONPATH", libexec/"python/lib/python/site-packages"
    ENV.prepend_path "PATH", libexec/'vendor/bin/'

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

    args << "-DWITH_POSTGRESQL=#{build.with?("postgresql") ? "TRUE" : "FALSE"}"
    if build.with? "postgresql"
      args << "-DPOSTGRES_CONFIG=#{Formula["postgresql"].opt_bin}/pg_config"
      args << "-DPOSTGRES_INCLUDE_DIR=#{Formula["postgresql"].opt_include}"
      args << "-DPOSTGRES_LIBRARY=#{Formula["postgresql"].opt_lib}/libpq.dylib"
    end

    args << "-DWITH_GRASS7=#{(build.with?("grass") || brewed_grass7?) ? "TRUE" : "FALSE"}"
    if build.with?("grass") || brewed_grass7?
      # this is to build the GRASS Plugin, not for Processing plugin support
      grass7 = Formula["grass7"]
      args << "-DGRASS_PREFIX7='#{grass7.opt_prefix}/grass-base'"
      # keep superenv from stripping (use Cellar prefix)
      ENV.append "CXXFLAGS", "-isystem #{grass7.prefix.resolved_path}/grass-base/include"
      # So that `libintl.h` can be found (use Cellar prefix; should not be needed anymore with QGIS 2.99+)
      # ENV.append "CXXFLAGS", "-isystem #{Formula["gettext"].include.resolved_path}"
    end

    # args << "-DWITH_GLOBE=#{build.with?("globe") ? "TRUE" : "FALSE"}"
    # if build.with? "globe"
    #   osg = Formula["open-scene-graph"]
    #   opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
    #   # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
    #   # args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    # end

    args << "-DWITH_ORACLE=#{build.with?("oracle") ? "TRUE" : "FALSE"}"
    if build.with? "oracle"
      oracle_opt = Formula["oracle-client-sdk"].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/include/oci"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    args << "-DWITH_QSPATIALITE=#{build.with?("qspatialite") ? "TRUE" : "FALSE"}"

    args << "-DWITH_APIDOC=#{build.with?("api-docs") ? "TRUE" : "FALSE"}"
    
    args << "-DWITH_3D=#{build.with?("3d") ? "TRUE" : "FALSE"}"
   
    # args << "-DWITH_QTWEBKIT=#{build.with?("qt5-webkit") ? "TRUE" : "FALSE"}"
    # if build.with? "qt5-webkit"
    #   args << "-DOPTIONAL_QTWEBKIT=" + Formula["qt-webkit"].opt_prefix + "/lib/cmake/Qt5WebKitWidgets"
    # end
    
    # prefer opt_prefix for CMake modules that find versioned prefix by default
    # this keeps non-critical dependency upgrades from breaking QGIS linking
    args << "-DGDAL_INCLUDE_DIR=#{Formula["gdal2"].opt_include}"
    args << "-DGDAL_LIBRARY=#{Formula["gdal2"].opt_lib}/libgdal.dylib"
    args << "-DGEOS_INCLUDE_DIR=#{Formula["geos"].opt_include}"
    args << "-DGEOS_LIBRARY=#{Formula["geos"].opt_lib}/libgeos_c.dylib"
    args << "-DGSL_CONFIG=#{Formula["gsl"].opt_bin}/gsl-config"
    args << "-DGSL_INCLUDE_DIR=#{Formula["gsl"].opt_include}"
    args << "-DGSL_LIBRARIES='-L#{Formula["gsl"].opt_lib} -lgsl -lgslcblas'"
      
    # args << "-DR_FOLDER=#{Formula["r"].opt_prefix}" if build.with? "r"

    # avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append "CXXFLAGS", "-F#{Formula["qt"].opt_lib}"

    # handle some compiler warnings
    # ENV["CXX_EXTRA_FLAGS"] = "-Wno-unused-private-field -Wno-deprecated-register"
    # if ENV.compiler == :clang && (MacOS::Xcode.version >= "7.0" || MacOS::CLT.version >= "7.0")
    #   ENV.append "CXX_EXTRA_FLAGS", "-Wno-inconsistent-missing-override"
    # end
    
    # create pyrcc5
    File.open("#{libexec}/vendor/bin/pyrcc5", "w") { |file|
			file << '#!/bin/sh'
			file << "\n"
			file << 'exec python3 -m PyQt5.pyrcc_main ${1+"$@"}'
    }
    
    # create pyuic5
    File.open("#{libexec}/vendor/bin/pyuic5", "w") { |file|
			file << '#!/bin/sh'
			file << "\n"
			file << 'exec python3 -m PyQt5.pyuic5_main ${1+"$@"}'
    }
    
    chmod("+x", "#{libexec}/vendor/bin/pyrcc5")
    chmod("+x", "#{libexec}/vendor/bin/pyuic5")
    
    mkdir "build" do
      system "cmake", "-G", build.with?("ninja") ? "Ninja" : "Unix Makefiles", *args, ".."
      system "cmake", "--build", ".", "--target", "all", "--", "-j", Hardware::CPU.cores
      system "cmake", "--build", ".", "--target", "install", "--", "-j", Hardware::CPU.cores
    end

    # fixup some errant lib linking
    # TODO: fix upstream in CMake
    dy_libs = [lib_qt/"plugins/designer/libqgis_customwidgets.dylib"]
    dy_libs << lib_qt/"plugins/sqldrivers/libqsqlspatialite.dylib" if build.with? "qspatialite"
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

    # update .app's bundle identifier, so other installers doesn't get confused
    inreplace prefix/"QGIS.app/Contents/Info.plist",
              "org.qgis.qgis3", "org.qgis.qgis3-hb#{build.head? ? "-dev" : ""}"

    py_lib = python_site_packages
    ln_s "../../../QGIS.app/Contents/Resources/python/qgis", py_lib/"qgis"

    ln_s "QGIS.app/Contents/MacOS/fcgi-bin", prefix/"fcgi-bin" if build.with? "server"

    doc.mkpath
    mv prefix/"QGIS.app/Contents/Resources/doc/api", doc/"api" if build.with? "api-docs"
    ln_s "../../../QGIS.app/Contents/Resources/doc", doc/"doc"

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    # TODO: for Py3
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

    # set qt's then install's libexec/python#{py_ver}/site-packages first, so app will work if unlinked
    pypths = %W[#{python_qt_site_packages} #{opt_libexec}/python#{py_ver}/site-packages #{pypth}]
      
    # set install's lib/python#{py_ver}/site-packages first, so app will work if unlinked
    # pypths = %W[
    #   #{opt_lib}/python#{py_ver}/site-packages
    #   #{opt_libexec}/python/lib/python/site-packages
    #   #{pypth}
    # ]

    pths.insert(0, gdal_opt_bin)
    pths.insert(0, gdal_python_opt_bin)
    pypths.insert(0, gdal_python_packages)

    # prepend qt based utils to PATH (reverse order)
    pths.insert(0, Formula["qca"].opt_bin.to_s)
    pths.insert(0, Formula["pyqt"].opt_bin.to_s)
    pths.insert(0, "#{Formula["sip"].opt_libexec}/bin")
    pths.insert(0, Formula["qt"].opt_bin.to_s)

    if opts.include?("with-gpsbabel")
      pths.insert(0, Formula["gpsbabel"].opt_bin.to_s)
    end

    # we need to manually add the saga lts path, since it's keg only
    if build.with? "saga-gis-lts"
      pths.insert(0, Formula["saga-gis-lts"].opt_bin.to_s)
    end

    envars = {
      :PATH => pths.join(pthsep),
      :PYTHONPATH => pypths.join(pthsep),
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins",
      :GDAL_DATA => "#{Formula["gdal2"].opt_share}/gdal",
    }
      
    # handle multiple Qt plugins directories
    qtplgpths = %W[
      #{opt_lib}/qt/plugins
      #{hb_lib_qt}/plugins
      #{Formula["qt"].opt_prefix}/plugins
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

    # if opts.include?("with-orfeo5") || brewed_orfeo5?
    #  orfeo5 = Formula["orfeo5"]
    #  begin
    #    inreplace app/"#{proc_algs}/otb/OTBUtils.py" do |s|
    #      # default geoid path
    #      # try to replace first, so it fails (if already done) before global replaces
    #      s.sub! "OTB_GEOID_FILE) or ''", "OTB_GEOID_FILE) or '#{orfeo5.opt_libexec}/default_geoid/egm96.grd'"
    #      # default bin and lib path
    #      s.gsub! "/usr/local/bin", orfeo5.opt_bin.to_s
    #      s.gsub! "/usr/local/lib", orfeo5.opt_lib.to_s
    #    end
    #    puts "ORFEO 5 OTBUtils.py has been updated"
    #    rescue Utils::InreplaceError
    #    puts "ORFEO 5 OTBUtils.py already updated"
    #  end
    # end

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
    s = <<~EOS
      Bottles support only Homebrew's Python3

      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in QGIS.app:
        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into /Applications or ~/Applications:
        ln -Fs `find $(brew --prefix) -name "QGIS.app"` /Applications/QGIS.app

      To directly run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper
      script pre-defined with Homebrew prefix environment variables:
        #{opt_bin}/#{name}

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app
            bundle they are not.

      For standalone Python development, set the following environment variable:
        export PYTHONPATH=#{libexec/"python3.7/site-packages"}:#{gdal_python_packages}:#{python_qt_site_packages}:#{python_site_packages}:$PYTHONPATH
    EOS

    if build.with? "isolation"
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
    %w[psycopg2 matplotlib pyparsing requests future jinja2 pygments].each do |m|
      xm << m unless module_importable? m
    end

    unless xm.empty?
      s += <<~EOS
        #{Tty.red}
        The following Python modules are needed by QGIS during run-time:

            #{xm.join(", ")}

        You can install manually, via installer package or with `pip` (if availble):

            pip3 install <module>  OR  pip-3.7 install <module>
        #{Tty.red}
        #{Tty.reset}
      EOS
    end

    # TODO: remove this when libqscintilla.dylib becomes core build dependency?
    unless module_importable? "PyQt.Qsci"
      s += <<~EOS
        QScintilla Python module is needed by QGIS during run-time.
        Ensure `qscintilla2` formula is linked.

      EOS
    end

    s += <<~EOS
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

  # def brewed_orfeo5?
  #   Formula["orfeo5"].opt_prefix.exist?
  # end

  def python_prefix
    `#{python_exec} -c 'import sys;print(sys.prefix)'`.strip
  end

  def py_ver
    `#{python_exec} -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end

  def python_site_packages
    libexec/"vendor/lib/python#{py_ver}/site-packages"
  end

  def brewed_python?
    Formula["python3"].linked_keg.exist?
  end

  def python_exec
    if brewed_python?
      Formula["python3"].opt_bin/"python3"
    else
      py_exec = `which python3`.strip
      raise if py_exec == ""
      py_exec
    end
  end

  def python_incdir
    Pathname.new(`#{python_exec} -c "from distutils import sysconfig; print(sysconfig.get_python_inc())"`.strip)
  end

  def python_libdir
    Pathname.new(`#{python_exec} -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBPL'))"`.strip)
  end

  def hb_lib_qt
    HOMEBREW_PREFIX/"lib/qt"
  end

  def python_qt_site_packages
    hb_lib_qt/"python#{py_ver}/site-packages"
  end

  def lib_qt
    lib/"qt"
  end

  def opt_lib_qt
    opt_lib/"qt"
  end

  def gdal_python_packages
    Formula["gdal2-python"].opt_lib/"python#{py_ver}/site-packages".to_s
  end

  def gdal_python_opt_bin
    Formula["gdal2-python"].opt_bin.to_s
  end

  def gdal_opt_bin
    Formula["gdal2"].opt_bin.to_s
  end

  def module_importable?(mod)
    # `#{python_exec} -c 'import sys;sys.path.insert(1, "#{gdal_python_packages}"); import #{mod}'`.strip
    quiet_system python_exec, "-c", "import sys;sys.path.insert(1, '#{python_qt_site_packages}'); import #{mod}"
  end
end
