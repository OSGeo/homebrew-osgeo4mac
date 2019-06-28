################################################################################
# Maintainer: FJ Perini @fjperini
# Collaborator: Luis Puerto @luispuerto
################################################################################

class UnlinkedQGIS < Requirement
  fatal true

  satisfy(:build_env => false) { !qt4_linked && !pyqt4_linked && !txt2tags_linked }

  def qt4_linked
    (Formula["qt-4"].linked_keg/"lib/QtCore.framework/Versions/4").exist?
  rescue
    return false
  end

  def pyqt4_linked
    (Formula["pyqt-qt4"].linked_keg/"lib/qt-4/python2.7/site-packages/PyQt4").exist?
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

    s += "Unlink with `brew unlink qt-4` or remove with `brew uninstall qt-4`\n" if qt4_linked
    s += "Unlink with `brew unlink pyqt-qt4` or remove with `brew uninstall pyqt-qt4`\n" if pyqt4_linked
    s += "Unlink with `brew unlink txt2tags` or remove with `brew uninstall txt2tags`\n" if txt2tags_linked
    s
  end
end

class OsgeoQgis < Formula
  desc "Open Source Geographic Information System"
  homepage "https://www.qgis.org"
  url "https://github.com/qgis/QGIS/archive/final-3_8_0.tar.gz"
  sha256 "f6db56b8cce8482933ec492b26376a2c62cb269cd1b722b374b6c828e35f258e"
  # version "3.8.0"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "2a576d409659dee8a6033356b06962aee01782dd7a00240039bf15ba880ba227" => :mojave
    sha256 "2a576d409659dee8a6033356b06962aee01782dd7a00240039bf15ba880ba227" => :high_sierra
    sha256 "7c7b0b8c196a716380ed817749a519680487fd82ec472e7ac347e8fa41b3b824" => :sierra
  end

  head "https://github.com/qgis/QGIS.git", :branch => "master"

  # fix FindQsci and FindPyQt5
  patch :DATA

  def pour_bottle?
    brewed_python?
  end

  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-ninja", "Disable use of ninja CMake generator"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "without-pyqt5-webkit", "Build without webkit python bindings"
  option "without-qgis-res", "Build without QGIS Resources support"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"
  option "with-isolation", "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option "with-mssql", "Build with Microsoft ODBC Driver for SQL Server"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-pg10", "Build with PostgreSQL 10 client"
  # option "with-globe", "Build with Globe plugin, based upon osgEarth"

  # Build with 3D Map View panel
  # Build with GPSBabel. Read, write and manipulate GPS waypoints in a variety of formats
  # Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)
  # Build with LAStools, efficient tools for LiDAR processing. Contains LASlib, a C++ programming API for reading / writing LIDAR data stored in standard LAS format.
  # Build extra Orfeo Toolbox for Processing plugin
  # Build QSpatialite Qt database driver
  # Build extra R for Processing plugin
  # Build extra Saga GIS (LTS) for Processing plugin
  # Build with QGIS Server (qgis_mapserv.fcgi)
  # Build with TauDEM, Terrain Analysis Using Digital Elevation Models for hydrology
  # Build with Whitebox Tools, an advanced geospatial data analysis platform

  deprecated_option "with-saga-gis-lts" => "with-saga"
  deprecated_option "with-postgresql10" => "with-pg10"

  depends_on UnlinkedQGIS

  # required
  depends_on "cmake" => :build
  depends_on "ninja" => [:build, :recommended]
  depends_on "gsl" => :build # Georeferencer plugin
  depends_on "six" => [:build, :recommended]
  depends_on "osgeo-sip" => [:build, :recommended]
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "pkg-config" => :build
  depends_on "python"
  depends_on "osgeo-gdal-python" # gdal - core providers
  depends_on "libzip"
  depends_on "osgeo-qscintilla2"
  depends_on "qca"
  depends_on "qt"
  depends_on "osgeo-pyqt"
  depends_on "osgeo-pyqt-webkit" # qt5-webkit
  depends_on "osgeo-qtkeychain"
  depends_on "qwt"
  depends_on "spatialindex"
  depends_on "sqlite"
  depends_on "expat"
  depends_on "osgeo-proj"
  depends_on "hdf5"
  depends_on "geos"
  depends_on "libtasn1"
  depends_on "osgeo-libspatialite"
  depends_on "qwtpolar"
  depends_on "desktop-file-utils"
  depends_on "hicolor-icon-theme"

  # recommended
  depends_on "openssl"
  depends_on "qjson"
  depends_on "unixodbc"
  # depends_on "libiodbc"
  depends_on "freetds"
  depends_on "osgeo-psqlodbc"
  depends_on "libpq"
  depends_on "osgeo-postgis"
  depends_on "exiv2"
  depends_on "osgeo-liblas"
  depends_on "osgeo-netcdf"
  depends_on "osgeo-pdal"
  depends_on "szip"
  depends_on "openvpn"
  depends_on "curl"
  depends_on "libiconv"
  depends_on "poppler"
  depends_on "gnu-sed"
  depends_on "git"
  depends_on "libxml2"
  depends_on "libffi"

  depends_on "numpy"
  depends_on "scipy"
  depends_on "osgeo-matplotlib"

  if build.with?("api-docs")
    depends_on "graphviz" => :build
    depends_on "doxygen" => :build
  end

  # requires python modules
  # jinja - MetaSearch
  # numpy - Processing
  # owslib - MetaSearch
  # psycopg2 - DB Manager and Processing
  # pygments - MetaSearch
  # yaml - Processing
  # many useful modules are incorporated
  depends_on "osgeo-qgis-res"

  # fcgi - server
  depends_on "fcgi"
  depends_on "spawn-fcgi"
  depends_on "lighttpd"

  # core plugins (c++ and python

  # grass
  depends_on "osgeo-grass"
  depends_on "gettext"

  depends_on "gpsbabel" # GPS Tools plugin

  # the Globe Plugin for QGIS 3 is still not available,
  # only for QGIS 2 and it does not support a larger version than OSGearh v2.7.
  # working on the implementation
  # if build.with? "globe"
  #   depends_on "osgeo-openscenegraph"
  #   depends_on "osgeo-osgqt"
  #   depends_on "osgeo-osgearth"
  # end

  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)
  # TODO: what to do for Py3 and pyspatialite?
  depends_on "osgeo-pyspatialite" # for DB Manager

  # use newer postgresql client than Apple's, also needed by `psycopg2`
  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  depends_on "osgeo-oracle-client-sdk" if build.with?("oracle")

  # TODO: add MSSQL third-party support formula?, :optional
  if build.with?("mssql")
    depends_on "microsoft/mssql-release/msodbcsql17"
    depends_on "microsoft/mssql-release/mssql-tools"
  end

  depends_on "osgeo-qt-psql"
  depends_on "osgeo-qt-odbc"
  depends_on "osgeo-qt-mysql" # for eVis plugin
  # depends_on "osgeo-qt-tds" # obsolete from Qt 4.7
  # depends_on "osgeo-qt-oci" # from oracle-client-sdk?

  # core processing plugin extras
  # see `grass` above
  depends_on "osgeo-orfeo"
  depends_on "osgeo-saga-lts"
  depends_on "osgeo-whitebox-tools"
  depends_on "osgeo-lastools"
  depends_on "osgeo-taudem"

  # R with more support
  # https://github.com/adamhsparks/setup_macOS_for_R
  # fix: will not build if the R version does not match
  # If you installed sethrfore/r-srf/r, before installing
  # rename "/usr/local/opt/r" to "/usr/local/Cellar/r-bk"
  # and then restore it after installing qgis
  depends_on "r" # optional

  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  # R Plugin
  resource "r" do
    url "https://github.com/north-road/qgis-processing-r/archive/51371402c0200b6649fa3daa8ca8067e83aa6c15.tar.gz"
    sha256 "f6309e1edc334f76938f46a396c71e986b1910dd8c4c58936cad8d7fad54a346"
    version "1.0.5"
  end

  # OTB Plugin
  unless build.head?
    resource "otb" do
      url "https://gitlab.orfeo-toolbox.org/orfeotoolbox/qgis-otb-plugin/-/archive/d5e8f0a2e11e9d1d5b28f1a0d1f9af1a4985b477/qgis-otb-plugin-d5e8f0a2e11e9d1d5b28f1a0d1f9af1a4985b477.tar.gz"
      sha256 "939b89065604c10ee3a1b61f186e494f8e734aae1856547a32b1cb296dc4895b"
      version "1.4.2"
    end
    # # Patch: OtbUtils
    # resource "OtbUtils" do
    #   url "https://gist.githubusercontent.com/fjperini/dc45ed0f637ae7dc8ec543a701e012f6/raw/c2b6bbafd6a9439bba903403f14c1b3c1ec3683d/OtbUtils.diff"
    #   sha256 "b02c2fba5751dea84284072c590ce969ef215bb54e06cc2043ccbaf4449189e5"
    # end
    # # Patch: OtbAlgorithmProvider
    # resource "OtbAlgorithmProvider" do
    #   url "https://gist.githubusercontent.com/fjperini/d8fe440818814c0800e5071a0ccb4f70/raw/034e1dc2950749fcf70b2fd2925df11aa6deaae3/OtbAlgorithmProvider.diff"
    #   sha256 "add76b970cee0c42bd56af50da1f77e1a214ae8912e6b8e3da6e82611ecc30b5"
    # end
  end

  # WhiteboxTools Plugin
  resource "whitebox" do
    url "https://github.com/alexbruy/processing-whitebox/archive/5cbd81240e2a4e08fa0df515bf3dbf11957998ea.tar.gz"
    sha256 "4ccf112dae81447842ccaa08a86d3c5fa12b0a1087e8dc485723a5c8737ebbd9"
    version "0.9.0"
  end
  # Patch: whiteboxProvider
  resource "whiteboxProvider" do
    url "https://gist.githubusercontent.com/fjperini/fcb9f964c5396ab8b72c874a8db41b1d/raw/154deb8f17d52d11f1fba2642d43df2b1d0d936d/whiteboxProvider.diff"
    sha256 "e95191b38765d6072c1a637e735114cce03d53173e47b96626bb30930b5e9c7f"
  end

  # TauDEM Plugin
  resource "taudem" do
    url "https://github.com/alexbruy/processing-taudem/archive/38dc454c477b6a6e917f2b3777dc69ed3ecd6062.tar.gz"
    sha256 "7df793ae6a26ed65b6b15a8c8151b7f8598118b9f8da920eb260049d7c57229d"
    version "2.0.0"
  end
  # Patch: taudemProvider
  resource "taudemProvider" do
    url "https://gist.githubusercontent.com/fjperini/1899e20e0286058a74116aecf466f0a0/raw/a2fc2c7a31c747fca5fbed4e885a6503fe6a5d4c/taudemProvider.diff"
    sha256 "39a494f886d00011a0101b40715d828465592f304590438a7658d03298950cf5"
  end
  # Patch: taudemUtils
  resource "taudemUtils" do
    url "https://gist.githubusercontent.com/fjperini/f3e5ed0e964f4b7ead80a7c39a7115f6/raw/c3c8cca96d51156d0f60fe487b5b848faa3d0c2c/taudemUtils.diff"
    sha256 "3cf403f74c2ed67f6cdfb87c04cf0b09b085fb9f77ddde9be1d7f2ac12fe53a3"
  end

  # LAStools Plugin
  resource "lastools" do
    url "https://github.com/rapidlasso/LAStoolsPluginQGIS3/archive/55866f1685c03c8f9771a6a995550e08095b1f8a.tar.gz"
    sha256 "0badea99da9f14ae02a50860e368c48953eea921bf732593a2c059c090e1c248"
    version "1.3"
  end
  # Patch: LAStoolsProvider
  resource "LAStoolsProvider" do
    url "https://gist.githubusercontent.com/fjperini/d6dd9f294be338fba4a05959b845f095/raw/4da2e9e0bd931ad00b3ca66777c3a9d50cde18ba/LAStoolsProvider.diff"
    sha256 "82656a9fd6f42056d5c2a5487f2429b7f2c66c83287852fb644517abccecc563"
  end

  # splash
  resource "splash" do
    url "https://bottle.download.osgeo.org/qgis-splash/splash-3.8.png"
    sha256 "e53726b42fc4e11c97f667b662a052ef25ef0c7d99d358e2ee3a21189d2bfc04"
  end

  def install
    ENV.cxx11

    # change splash
    rm "#{buildpath}/images/splash/splash.png"
    (buildpath/"images/splash").install resource("splash")
    mv "#{buildpath}/images/splash/splash-3.8.png", "#{buildpath}/images/splash/splash.png"

    # suggestions before installing
    printf  "\n\033[31mSome suggestions that you should keep in mind!!!\e[0m\n\n"
    printf  "- In case you have installed another version of Python\e[0m (Anaconda, Miniconda or if you used the installer provided by python.org),\n"
    printf  "  QGIS will use the first Python that is in its PATH, so the installation may fail.\n\n"
    printf  "- If the installation failed due to the problem reported in \e[32mhttps://github.com/OSGeo/homebrew-osgeo4mac/issues/520\e[0m\n\n"
    printf  "  Try after doing:\n\n"
    printf  "    \e[32m$ brew unlink python && brew link --force python\e[0m  \e[1;33m(*)\e[0m\n\n"
    printf  "    \e[32m$ $PATH (Check that there is no other version)\e[0m\n\n"
    printf  "- If the installation failed due to the problem reported in \e[32mhttps://github.com/OSGeo/homebrew-osgeo4mac/issues/510\e[0m\n\n"
    printf  "  Try after doing:\n\n"
    printf  "    \e[32m$ brew reinstall ninja gsl python qt osgeo-sip osgeo-pyqt osgeo-pyqt-webkit osgeo-qscintilla2 six bison flex pkg-config\e[0m\n\n"
    printf  "    \e[32m$ brew link --overwrite osgeo-pyqt\e[0m  \e[1;33m(**)\e[0m\n\n"
    printf  "- Other Notes:\n\n"
    printf  "    - An installation that failed previously may have created this link\n\n"
    printf  "      \033[31m#{HOMEBREW_PREFIX}/lib/python#{py_ver}/site-packages/PyQt5/uic/widget-plugins/qgis_customwidgets.py\e[0m, you will need to delete it.\n\n"
    printf  "    - Also make sure that the folder \033[31m#{HOMEBREW_PREFIX}/Cellar/qgis\e[0m does not exist if the installation fails.\n\n"
    printf  "    - It is also recommended remove the Homebrew Cache \e[32m$ rm -rf $(brew --cache)\e[0m (\e[32m~/Library/Caches/Homebrew\e[0m) and the temporary build files in \e[32m/tmp\e[0m.\n\n"
    printf  "    - If you are going to install with several options you may have the following error:\n\n"
    printf  "      \033[31mError: Too many open files @ rb_sysopen - #{HOMEBREW_PREFIX}/var/homebrew/locks/..\e[0m\n\n"
    printf  "      Check before with: \e[32m$ ulimit -n\e[0m\n"
    printf  "      You can change it temporarily to avoid this problem: \e[32m$ ulimit -n 1024\e[0m\n"
    printf  "      Will be re-established in the next session\n\n"
    printf  "    - If the installation failed with the error\n\n"
    printf  "      \033[31mfatal error: 'libintl.h' file not found\e[0m\n\n"
    printf  "      Try after doing: \e[32m$ brew unlink gettext && brew link --force gettext\e[0m  \e[1;33m(***)\e[0m\n\n"
    printf  "\n\033[31mWe recommend that you run on the terminal\e[0m \e[1;33m(*)\e[0m\033[31m,\e[1;33m(**)\e[0m \033[31mand\e[0m \e[1;33m(***)\e[0m \033[31mbefore installation,\e[0m\n"
    printf  "\n\033[31mto make sure everything works correctly.\e[0m\n\n"
    printf "\033[31mThe installation will continue, but remember the above.\e[0m\n"

    30.downto(0) do |i|
        printf "#{'%02d'% i}."
        sleep 1
    end

    printf "\n\n"

    # proceeds to install the add-ons as a first step,
    # to ensure that the patches are applied
    mkdir "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"

    # OTB is available from branch_3.8
    unless build.head?
    #   resource("otb").stage do
    #     cp_r "./otb", "#{buildpath}/python/plugins/"
    #   end
      resource("otb").stage do
        cp_r "./otb", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"
      end
    #   resource("OtbUtils").stage do
    #     cp_r "./OtbUtils.diff", "#{buildpath}"
    #   end
    #   resource("OtbAlgorithmProvider").stage do
    #     cp_r "./OtbAlgorithmProvider.diff", "#{buildpath}"
    #   end
    #   system "patch", "-p1", "-i", "#{buildpath}/OtbUtils.diff"
    #   system "patch", "-p1", "-i", "#{buildpath}/OtbAlgorithmProvider.diff"
    #   cp_r "#{buildpath}/python/plugins/otb", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"
    end

    # R
    resource("r").stage do
      cp_r "./processing_r", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"
    end

    # WhiteboxTools
    resource("whitebox").stage do
      cp_r "./", "#{buildpath}/python/plugins/processing_whitebox"
    end
    resource("whiteboxProvider").stage do
      cp_r "./whiteboxProvider.diff", "#{buildpath}"
    end
    system "patch", "-p1", "-i", "#{buildpath}/whiteboxProvider.diff"
    cp_r "#{buildpath}/python/plugins/processing_whitebox", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"

    # TauDEM
    resource("taudem").stage do
      cp_r "./", "#{buildpath}/python/plugins/processing_taudem"
    end
    resource("taudemProvider").stage do
      cp_r "./taudemProvider.diff", "#{buildpath}"
    end
    resource("taudemUtils").stage do
      cp_r "./taudemUtils.diff", "#{buildpath}"
    end
    system "patch", "-p1", "-i", "#{buildpath}/taudemProvider.diff"
    system "patch", "-p1", "-i", "#{buildpath}/taudemUtils.diff"
    cp_r "#{buildpath}/python/plugins/processing_taudem", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"

    # LASTools
    resource("lastools").stage do
      cp_r "./LAStools", "#{buildpath}/python/plugins/lastools"
    end
    resource("LAStoolsProvider").stage do
      cp_r "./LAStoolsProvider.diff", "#{buildpath}"
    end
    system "patch", "-p1", "-i", "#{buildpath}/LAStoolsProvider.diff"
    cp_r "#{buildpath}/python/plugins/lastools", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"

    # if you have a 3rd party Python installed, and/or Python 3,
    # you need to remove it from your path for the installation.
    # once installed, QGIS will run even if the primary Python is,
    # for example, Anaconda Python 3.
    # reset path
    ENV["PATH"] = nil
    pths = "#{HOMEBREW_PREFIX}/bin:#{HOMEBREW_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/X11/bin"
    ENV.append_path "PATH", "#{pths}"

    # when osgeo-gdal-python.rb loaded, PYTHONPATH gets set to 2.7 site-packages...
    # clear it before calling any local python3 functions
    ENV["PYTHONPATH"] = nil
    if ARGV.debug?
      puts "brewed_python?: #{brewed_python?}"
      puts "python_prefix: #{python_prefix}"
      puts "python_exec: #{python_exec}"
      puts "py_ver: #{py_ver}"
      puts "python_site_packages: #{python_site_packages}"
      puts "qgis_site_packages: #{qgis_site_packages}"
      puts "qgis_python_packages: #{qgis_python_packages}"
      puts "gdal_python_packages: #{gdal_python_packages}"
      puts "gdal_python_opt_bin: #{gdal_python_opt_bin}"
      puts "gdal_opt_bin: #{gdal_opt_bin}"
    end

    # set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.

    # install custom widgets Designer plugin to local qt plugins prefix
    mkdir lib/"qt/plugins/designer"
    inreplace "src/customwidgets/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/designer", lib/"qt/plugins/designer".to_s

    # fix custom widgets Designer module install path
    mkdir lib/"python#{py_ver}/site-packages/PyQt5"
    inreplace "CMakeLists.txt",
              "${PYQT5_MOD_DIR}", lib/"python#{py_ver}/site-packages/PyQt5".to_s

    # install db plugins to local qt plugins prefix
    # qspatialite
    mkdir lib/"qt/plugins/sqldrivers"
    inreplace "external/qspatialite/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s

    # end
    if build.with? "oracle"
      mkdir lib/"qt/plugins/sqldrivers"
      inreplace "src/providers/oracle/ocispatial/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s
    end

    # support for PROJ 6
    # https://github.com/OSGeo/proj.4/wiki/proj.h-adoption-status
    # ENV.append "CFLAGS", "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"

    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override

    cmake_prefixes = %w[
      qt
      osgeo-qt-webkit
      osgeo-pyqt-webkit
      osgeo-qscintilla2
      osgeo-pyqt
      osgeo-sip
      qwt
      qwtpolar
      qca
      osgeo-qtkeychain
      osgeo-gdal
      gsl
      geos
      osgeo-proj
      osgeo-libspatialite
      spatialindex
      expat
      sqlite
      libzip
      flex
      bison
      fcgi
    ].freeze

    # force CMake to search HB/opt paths first, so headers in HB/include are not found instead;
    # specifically, ensure any gdal v1 includes are not used
    args << "-DCMAKE_PREFIX_PATH=#{cmake_prefixes.map { |f| Formula[f.to_s].opt_prefix }.join(";")}"

    qwt_fw = Formula["qwt"].opt_lib/"qwt.framework"
    qwtpolar_fw = Formula["qwtpolar"].opt_lib/"qwtpolar.framework"
    qca_fw = Formula["qca"].opt_lib/"qca-qt5.framework"
    args += %W[
      -DBISON_EXECUTABLE=#{Formula["bison"].opt_bin}/bison
      -DEXPAT_INCLUDE_DIR=#{Formula["expat"].opt_include}
      -DEXPAT_LIBRARY=#{Formula["expat"].opt_lib}/libexpat.dylib
      -DFLEX_EXECUTABLE=#{Formula["flex"].opt_bin}/flex
      -DPROJ_INCLUDE_DIR=#{Formula["osgeo-proj"].opt_include}
      -DPROJ_LIBRARY=#{Formula["osgeo-proj"].opt_lib}/libproj.dylib
      -DQCA_INCLUDE_DIR=#{qca_fw}/Headers
      -DQCA_LIBRARY=#{qca_fw}/qca-qt5
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DSPATIALINDEX_INCLUDE_DIR=#{Formula["spatialindex"].opt_include}
      -DSPATIALINDEX_LIBRARY=#{Formula["spatialindex"].opt_lib}/libspatialindex.dylib
      -DSQLITE3_INCLUDE_DIR=#{Formula["sqlite"].opt_include}
      -DSQLITE3_LIBRARY=#{Formula["sqlite"].opt_lib}/libsqlite3.dylib
      -DLIBZIP_CONF_INCLUDE_DIR=#{Formula["libzip"].opt_lib}/pkgconfig
      -DLIBZIP_INCLUDE_DIR=#{Formula["libzip"].opt_include}
      -DLIBZIP_LIBRARY=#{Formula["libzip"].opt_lib}/libzip.dylib
      -DSPATIALITE_INCLUDE_DIR=#{Formula["osgeo-libspatialite"].opt_include}
      -DSPATIALITE_LIBRARY=#{Formula["osgeo-libspatialite"].opt_lib}/libspatialite.dylib
      -DQTKEYCHAIN_INCLUDE_DIR=#{Formula["qtkeychain"].opt_include}/qt5keychain
      -DQTKEYCHAIN_LIBRARY=#{Formula["osgeo-qtkeychain"].opt_lib}/libqt5keychain.dylib
      -DLIBTASN1_INCLUDE_DIR=#{Formula["libtasn1"].opt_include}
      -DLIBTASN1_LIBRARY=#{Formula["libtasn1"].opt_lib}/libtasn1.dylib
      -DPYRCC_PROGRAM=#{libexec}/vendor/bin/pyrcc5
      -DPYUIC_PROGRAM=#{libexec}/vendor/bin/pyuic5
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DWITH_QSCIAPI=FALSE
      -DWITH_CUSTOM_WIDGETS=TRUE
      -DWITH_ASTYLE=FALSE
      -DWITH_QTWEBKIT=TRUE
      -DQT_LRELEASE_EXECUTABLE=#{Formula["qt"].opt_bin}/lrelease
      -DQT5_3DEXTRA_INCLUDE_DIR=#{Formula["qt"].opt_lib}/cmake/Qt53DExtras
      -DQt5WebKitWidgets_DIR=#{Formula["osgeo-qt-webkit"].opt_lib}/cmake/Qt5WebKitWidgets
      -DQt5WebKit_DIR=#{Formula["osgeo-qt-webkit"].opt_lib}/cmake/Qt5WebKit
    ]

    args << "-DQGIS_MACAPP_BUNDLE=0"
    args << "-DQGIS_MACAPP_INSTALL_DEV=FALSE"
    # args << "-DQGIS_APP_NAME=QGIS-HB"

    # Build unit tests
    args << "-DENABLE_TESTS=FALSE"
    # Enable QT ModelTest (not for production)
    args << "-DENABLE_MODELTEST=FALSE"
    # Perform coverage tests
    args << "-DENABLE_COVERAGE=FALSE"

    args << "-DSIP_BINARY_PATH=#{Formula["osgeo-sip"].opt_bin}/sip"
    args << "-DSIP_DEFAULT_SIP_DIR=#{HOMEBREW_PREFIX}/share/sip"
    args << "-DSIP_INCLUDE_DIR=#{Formula["osgeo-sip"].opt_include}"
    args << "-DSIP_MODULE_DIR=#{Formula["osgeo-sip"].opt_lib}/python#{py_ver}/site-packages"

    args << "-DPYQT5_MOD_DIR=#{Formula["python"].opt_prefix}/Frameworks/Python.framework/Versions/#{py_ver}/lib/python#{py_ver}/site-packages/PyQt5"
    args << "-DPYQT5_SIP_DIR=#{HOMEBREW_PREFIX}/share/sip/PyQt5" # Qt5
    args << "-DPYQT5_BIN_DIR=#{Formula["python"].opt_prefix}/Frameworks/Python.framework/Versions/#{py_ver}/bin"
    args << "-DPYQT5_SIP_IMPORT=PyQt5.sip"
    args << "-DPYQT5_SIP_FLAGS=-n PyQt5.sip -t WS_MACX -t Qt_5_12_1"

    args << "-DQSCI_SIP_DIR=#{HOMEBREW_PREFIX}/share/sip/PyQt5/Qsci" # Qsci/qscimod5.sip
    args << "-DQSCINTILLA_INCLUDE_DIR=#{Formula["osgeo-qscintilla2"].opt_include}" # Qsci/qsciglobal.h
    args << "-DQSCINTILLA_LIBRARY=#{Formula["osgeo-qscintilla2"].opt_lib}/libqscintilla2_qt5.dylib"

    # disable CCache
    args << "-DUSE_CCACHE=OFF"

    # Determines whether QGIS core should be built
    args << "-DWITH_CORE=TRUE"

    # Determines whether QGIS GUI library (and everything built on top of it) should be built
    args << "-DWITH_GUI=TRUE"

    # Determines whether QGIS analysis library should be built
    # args << "-DWITH_ANALYSIS=TRUE"

    # Determines whether QGIS desktop should be built
    args << "-DWITH_DESKTOP=TRUE"

    # Determines whether QGIS Quick library should be built
    args << "-DWITH_QUICK=FALSE"

    # Determines whether MDAL support should be built
    args << "-DWITH_INTERNAL_MDAL=TRUE"

    # Determines whether GeoReferencer plugin should be built
    args << "-DWITH_GEOREFERENCER=TRUE"

    # Determines whether std::thread_local should be used
    args << "-DWITH_THREAD_LOCAL=TRUE"

    # Determines whether Qt5SerialPort should be tried for GPS positioning
    # args << "-DWITH_QT5SERIALPORT=TRUE"

    # Use Clang tidy
    args << "-DWITH_CLANG_TIDY=FALSE"

    # try to configure and build python bindings by default
    # determines whether python bindings should be built
    args << "-DWITH_BINDINGS=TRUE"
    # by default bindings will be installed only to QGIS directory
    # someone might want to install it to python site-packages directory
    # as otherwise user has to use PYTHONPATH environment variable to add
    # QGIS bindings to package search path
    # install bindings to global python directory? (might need root)
    args << "-DBINDINGS_GLOBAL_INSTALL=FALSE"
    # Stage-install core Python plugins to run from build directory? (utilities and console are always staged)
    args << "-DWITH_STAGED_PLUGINS=TRUE"
    # Determines whether Python modules in staged or installed locations are byte-compiled"
    args << "-DWITH_PY_COMPILE=FALSE"

    # python Configuration
    args << "-DPYTHON_EXECUTABLE=#{`#{Formula["python"].opt_bin}/python3 -c "import sys; print(sys.executable)"`.chomp}"
    # args << "-DPYTHON_INCLUDE_PATH=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{py_ver}/include/python#{py_ver}m"
    # args << "-DPYTHON_LIBRARY=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{py_ver}/Python"
    # args << "-DPYTHON_SITE_PACKAGES_DIR=#{HOMEBREW_PREFIX}/lib/python#{py_ver}/site-packages"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = python_prefix if brewed_python?

    # handle custom site-packages for keg-only modules and packages
    ENV.append_path "PYTHONPATH", "#{python_site_packages}"
    ENV.append_path "PYTHONPATH", "#{qgis_site_packages}"
    ENV.append_path "PYTHONPATH", "#{qgis_python_packages}"
    ENV.append_path "PYTHONPATH", "#{gdal_python_packages}"

    # find git revision for HEAD build
    if build.head? && File.exist?("#{cached_download}/.git/index")
      args << "-DGITCOMMAND=#{Formula["git"].opt_bin}/git"
      args << "-DGIT_MARKER=#{cached_download}/.git/index"

      # disable OpenCL support
      # necessary to build from branch: master
      # fix for CL/cl2.hpp
      # https://github.com/qgis/QGIS/pull/7451
      # args << "-DUSE_OPENCL=OFF"
    end

    # used internal sources
    # args << "OPENCL_HPP_INCLUDE_DIR="

    # server
    args << "-DWITH_SERVER=TRUE"
    args << "-DWITH_SERVER_PLUGINS=TRUE"
    fcgi_opt = Formula["fcgi"].opt_prefix
    args << "-DFCGI_INCLUDE_DIR=#{fcgi_opt}/include"
    args << "-DFCGI_LIBRARY=#{fcgi_opt}/lib/libfcgi.dylib"

    # postgresql
    args << "-DWITH_POSTGRESQL=TRUE"
    if build.with?("pg10")
      args << "-DPOSTGRES_CONFIG=#{Formula["osgeo-postgresql@10"].opt_bin}/pg_config"
      args << "-DPOSTGRES_INCLUDE_DIR=#{Formula["osgeo-postgresql@10"].opt_include}"
      args << "-DPOSTGRES_LIBRARY=#{Formula["osgeo-postgresql@10"].opt_lib}/libpq.dylib"
    else
      args << "-DPOSTGRES_CONFIG=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
      args << "-DPOSTGRES_INCLUDE_DIR=#{Formula["osgeo-postgresql"].opt_include}"
      args << "-DPOSTGRES_LIBRARY=#{Formula["osgeo-postgresql"].opt_lib}/libpq.dylib"
    end

    # grass
    args << "-DWITH_GRASS7=TRUE"
    args << "-DWITH_GRASS=FALSE" # grass6
    # this is to build the GRASS Plugin, not for Processing plugin support
    grass = Formula["osgeo-grass"]
    args << "-DGRASS_PREFIX7=#{grass.opt_prefix}/grass-base"
    # keep superenv from stripping (use Cellar prefix)
    ENV.append "CXXFLAGS", "-isystem #{grass.prefix.resolved_path}/grass-base/include"
    # So that `libintl.h` can be found (use Cellar prefix; should not be needed anymore with QGIS 2.99+)
    ENV.append "CXXFLAGS", "-isystem #{Formula["gettext"].include.resolved_path}"

    # args << "-DWITH_GLOBE=TRUE"
    # osg = Formula["osgeo-openscenegraph"]
    # osgqt = Formula["osgqt"]
    # osgearth = Formula["osgeo-osgearth"]
    # opoo "`osgeo-openscenegraph` formula's keg not linked." unless osg.linked_keg.exist?
    # # OSG
    # # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
    # args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    # args << "-DOSG_DIR=#{osg.opt_prefix}"
    # args << "-DOSG_INCLUDE_DIR=#{osg.opt_include}" # osg/Node
    # args << "-DOSG_GEN_INCLUDE_DIR=#{osg.opt_include}" # osg/Config
    # args << "-DOSG_LIBRARY=#{osg.opt_lib}/libosg.dylib"
    # args << "-DOSGUTIL_LIBRARY=#{osg.opt_lib}/libosgUtil.dylib"
    # args << "-DOSGDB_LIBRARY=#{osg.opt_lib}/libosgDB.dylib"
    # args << "-DOSGTEXT_LIBRARY=#{osg.opt_lib}/libosgText.dylib"
    # args << "-DOSGTERRAIN_LIBRARY=#{osg.opt_lib}/libosgTerrain.dylib"
    # args << "-DOSGFX_LIBRARY=#{osg.opt_lib}/libosgFX.dylib"
    # args << "-DOSGSIM_LIBRARY=#{osg.opt_lib}/libosgSim.dylib"
    # args << "-DOSGVIEWER_LIBRARY=#{osg.opt_lib}/libosgViewer.dylib"
    # args << "-DOSGGA_LIBRARY=#{osg.opt_lib}/libosgGA.dylib"
    # args << "-DOSGQT_LIBRARY=#{osgqt.opt_lib}/libosgQt5.dylib"
    # args << "-DOSGWIDGET_LIBRARY=#{osg.opt_lib}/libosgWidget.dylib"
    # args << "-DOPENTHREADS_LIBRARY=#{osg.opt_lib}/libOpenThreads.dylib"
    # # args << "-DOPENTHREADS_INCLUDE_DIR=#{osg.opt_include}"
    # # args << "-DOSGSHADOW_LIBRARY=#{osg.opt_lib}/libosgShadow.dylib"
    # # args << "-DOSGMANIPULATOR_LIBRARY=#{osg.opt_lib}/libosgManipulator.dylib"
    # # args << "-DOSGPARTICLE_LIBRARY=#{osg.opt_lib}/libosgParticle.dylib"
    # # OSGEARTH
    # args << "-DOSGEARTH_DIR=#{osgearth.opt_prefix}"
    # args << "-DOSGEARTH_INCLUDE_DIR=#{osgearth.opt_include}" # osgEarth/TileSource
    # args << "-DOSGEARTH_GEN_INCLUDE_DIR=#{osgearth.opt_include}" # osgEarth/Common
    # args << "-DOSGEARTH_ELEVATION_QUERY=#{osgearth.opt_include}" # osgEarth/ElevationQuery
    # args << "-DOSGEARTH_LIBRARY=#{osgearth.opt_lib}/libosgEarth.dylib"
    # args << "-DOSGEARTHUTIL_LIBRARY=#{osgearth.opt_lib}/libosgEarthUtil.dylib"
    # args << "-DOSGEARTHFEATURES_LIBRARY=#{osgearth.opt_lib}/libosgEarthFeatures.dylib"
    # args << "-DOSGEARTHSYMBOLOGY_LIBRARY=#{osgearth.opt_lib}/libosgEarthSymbology.dylib"
    # args << "-DOSGEARTHQT_LIBRARY=#{osgearth.opt_lib}/libosgEarthQt5.dylib"
    # args << "-DOSGEARTHANNOTATION_LIBRARY=#{osgearth.opt_lib}/libosgEarthAnnotation.dylib"
    # # qt
    # args << "-DQt5OpenGL_INCLUDE_DIRS=#{Formula["qt"].opt_include}/QtOpenGL"

    args << "-DWITH_ORACLE=#{build.with?("oracle") || brewed_oracle? ? "TRUE" : "FALSE"}"
    if build.with?("oracle") || brewed_oracle?
      oracle_opt = Formula["osgeo-oracle-client-sdk"].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/include/oci"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    args << "-DWITH_QSPATIALITE=TRUE"

    args << "-DWITH_APIDOC=#{build.with?("api-docs") ? "TRUE" : "FALSE"}"

    args << "-DWITH_3D=TRUE"

    # args << "-DWITH_QTWEBKIT=#{build.with?("osgeo-qt-webkit") ? "TRUE" : "FALSE"}"
    # if build.with? "qtwebkit"
    #   args << "-DOPTIONAL_QTWEBKIT=#{Formula["osgeo-qt-webkit"].opt_lib}/cmake/Qt5WebKitWidgets"
    # end

    # prefer opt_prefix for CMake modules that find versioned prefix by default
    # this keeps non-critical dependency upgrades from breaking QGIS linking
    args << "-DGDAL_CONFIG=#{Formula["osgeo-gdal"].opt_bin}/gdal-config"
    args << "-DGDAL_INCLUDE_DIR=#{Formula["osgeo-gdal"].opt_include}"
    args << "-DGDAL_LIBRARY=#{Formula["osgeo-gdal"].opt_lib}/libgdal.dylib"
    args << "-DGEOS_CONFIG=#{Formula["geos"].opt_bin}/geos-config"
    args << "-DGEOS_INCLUDE_DIR=#{Formula["geos"].opt_include}"
    args << "-DGEOS_LIBRARY=#{Formula["geos"].opt_lib}/libgeos_c.dylib"
    args << "-DGSL_CONFIG=#{Formula["gsl"].opt_bin}/gsl-config"
    args << "-DGSL_INCLUDE_DIR=#{Formula["gsl"].opt_include}"
    args << "-DGSL_LIBRARIES='-L#{Formula["gsl"].opt_lib} -lgsl -lgslcblas'"

    # avoid ld: framework not found QtSql
    # (https://github.com/Homebrew/homebrew-science/issues/23)
    ENV.append "CXXFLAGS", "-F#{Formula["qt"].opt_lib}"

    # handle some compiler warnings
    # ENV["CXX_EXTRA_FLAGS"] = "-Wno-unused-private-field -Wno-deprecated-register"
    # if ENV.compiler == :clang && (MacOS::Xcode.version >= "7.0" || MacOS::CLT.version >= "7.0")
    #   ENV.append "CXX_EXTRA_FLAGS", "-Wno-inconsistent-missing-override"
    # end

    args << "-DCMAKE_CXX_FLAGS=-Wno-deprecated-declarations"

    # If set to true, it will disable deprecated functionality to prepare for the next generation of QGIS
    # args << "-DDISABLE_DEPRECATED=TRUE"

    # Newer versions of UseQt4.cmake include Qt with -isystem automatically
    # This can be used to force this behavior on older systems
    # Can be removed as soon as Travis-CI updates from precise
    # args << "-DSUPPRESS_QT_WARNINGS=TRUE"

    ENV.prepend_path "PATH", libexec/"vendor/bin"

    mkdir "#{libexec}/vendor/bin"

    # create pyrcc5
    File.open("#{libexec}/vendor/bin/pyrcc5", "w") { |file|
			file << '#!/bin/sh'
			file << "\n"
			file << 'exec' + " #{Formula["python"].opt_bin}/python3 " + '-m PyQt5.pyrcc_main ${1+"$@"}'
    }

    # create pyuic5
    File.open("#{libexec}/vendor/bin/pyuic5", "w") { |file|
			file << '#!/bin/sh'
			file << "\n"
			file << 'exec' + " #{Formula["python"].opt_bin}/python3 " + '-m PyQt5.pyuic5_main ${1+"$@"}'
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
    dy_libs = [lib/"qt/plugins/designer/libqgis_customwidgets.dylib"]
    dy_libs << lib/"qt/plugins/sqldrivers/libqsqlspatialite.dylib" # qspatialite
    dy_libs << lib/"qt/plugins/sqldrivers/libqsqlocispatial.dylib" if build.with? "oracle"
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
              "org.qgis.qgis3", "org.qgis.osgeo-qgis-hb#{build.head? ? "-dev" : ""}"

    py_lib = lib/"python#{py_ver}/site-packages"
    py_lib.mkpath
    ln_s "../../../QGIS.app/Contents/Resources/python/qgis", py_lib/"qgis"

    ln_s "QGIS.app/Contents/MacOS/fcgi-bin", prefix/"fcgi-bin" # server

    doc.mkpath
    mv prefix/"QGIS.app/Contents/Resources/doc/api", doc/"api" if build.with? "api-docs"
    ln_s "../../../QGIS.app/Contents/Resources/doc", doc/"doc"

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    # TODO: for Py3
    cp_r "#{Formula["osgeo-qgis-res"].opt_libexec}/pyqgis_startup.py", "#{libexec}/pyqgis_startup.py"

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
    pypth = "#{python_site_packages}"
    pths = %W[#{HOMEBREW_PREFIX}/bin #{HOMEBREW_PREFIX}/sbin /usr/bin /bin /usr/sbin /sbin /opt/X11/bin /usr/X11/bin]

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

    # set install's lib/python#{py_ver}/site-packages first, so app will work if unlinked
    pypths = %W[#{qgis_python_packages} #{qgis_site_packages} #{pypth}]

    pths.insert(0, "#{gdal_opt_bin}")
    pths.insert(0, "#{gdal_python_opt_bin}")
    pypths.insert(0, "#{gdal_python_packages}")

    # prepend qt based utils to PATH (reverse order)
    pths.insert(0, "#{Formula["qca"].opt_bin}")
    pths.insert(0, "#{Formula["osgeo-pyqt"].opt_bin}")
    pths.insert(0, "#{Formula["osgeo-sip"].opt_bin}")
    pths.insert(0, "#{Formula["qt"].opt_bin}")

    pths.insert(0, "#{Formula["gpsbabel"].opt_bin}")

    # we need to manually add the saga lts path, since it's keg only
    pths.insert(0, "#{Formula["osgeo-saga-lts"].opt_bin}")

    envars = {
      :PATH => pths.join(pthsep),
      :QGIS_BUNDLE => "#{opt_prefix}/QGIS.app/Contents",
      :QGIS_PREFIX_PATH => "#{opt_prefix}/QGIS.app/Contents/MacOS",
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins",
      :GDAL_DATA => "#{Formula["osgeo-gdal"].opt_share}/gdal",
      :CHECK_DISK_FREE_SPACE => "FALSE",
      :PYTHONPATH => pypths.join(pthsep),
      # if it is set, grass it will not work correctly, using Python 2
      # it will be necessary to wait until it is built with Python 3
      # :PYTHONHOME =>  "#{Formula["python"].opt_frameworks}/Python.framework/Versions/#{py_ver}",
    }

    # handle multiple Qt plugins directories
    qtplgpths = %W[
      #{opt_lib}/qt/plugins
      #{Formula["qt"].opt_prefix}/plugins
      #{HOMEBREW_PREFIX}/lib/qt/plugins
    ]
    envars[:QT_PLUGIN_PATH] = qtplgpths.join(pthsep)
    envars[:QT_AUTO_SCREEN_SCALE_FACTOR] = "1"
    # https://github.com/OSGeo/homebrew-osgeo4mac/issues/447
    # envars[:QT_AUTO_SCREEN_SCALE_FACTOR] = "0"
    # envars[:QT_DEVICE_PIXEL_RATIO] = "1"

    proc_plugins = "#{app}/Contents/Resources/python/plugins"
    proc_plugins_algs = "#{proc_plugins}/processing/algs"

    # for core integration plugin support

    # grass
    grass = Formula["osgeo-grass"]
    grass_version = "#{grass.version}"
    envars[:GRASS_PREFIX] = "#{grass.opt_prefix}/grass-base"
    envars[:GRASS_SH] = "/bin/sh"
    envars[:GRASS_PROJSHARE] = "#{Formula["osgeo-proj"].opt_share}"
    envars[:GRASS_VERSION] = "#{grass_version}"
    envars[:GRASS_LD_LIBRARY_PATH] = "#{grass.opt_prefix}/grass#{majmin_ver}/lib"
    # envars[:GRASS_PERL] = "#{Formula["perl"].opt_bin}/perl"
    envars[:PROJ_LIB] = "#{Formula["osgeo-proj"].opt_lib}"
    envars[:GEOTIFF_CSV] = "#{Formula["osgeo-libgeotiff"].opt_share}/epsg_csv"
    # envars[:R_HOME] = "#{Formula["r"].opt_bin}/R"
    # envars[:R_HOME] = "/Applications/RStudio.app/Contents/MacOS/RStudio"
    # envars[:R_USER] = "USER_PROFILE/Documents"
    begin
      inreplace "#{proc_plugins_algs}/grass7/Grass7Utils.py",
                "'/Applications/GRASS-7.{}.app/Contents/MacOS'.format(version)",
                "'#{grass.opt_prefix}/grass-base'"
      puts "GRASS 7 GrassUtils.py has been updated"
      rescue Utils::InreplaceError
      puts "GRASS 7 GrassUtils.py already updated"
    end

    # OTB is available from branch_3.8
    # unless build.head?
    #   orfeo = Formula["osgeo-orfeo"]
    #   # envars[:QGIS_PLUGINPATH] = "#{orfeo.opt_prefix}"
    #   begin
    #     inreplace "#{proc_plugins}/otb/OTBUtils.py" do |s|
    #     # default geoid path
    #     # try to replace first, so it fails (if already done) before global replaces
    #     s.sub! "OTB_FOLDER", "#{orfeo.opt_prefix}"
    #     s.sub! "OTB_APP_FOLDER", "#{orfeo.opt_lib}/otb/applications"
    #     s.sub! "OTB_GEOID_FILE", "#{orfeo.opt_libexec}/default_geoid/egm96.grd"
    #     end
    #     puts "ORFEO 6 OTBUtils.py has been updated"
    #     rescue Utils::InreplaceError
    #     puts "ORFEO 6 OTBUtils.py already updated"
    #   end
    # end

    # R
    # Remove setting to activate provider
    # See: https://github.com/north-road/qgis-processing-r/commit/7d8d182962392297690c02f77829b8cd64b5e8a9#diff-ce2ac984448f961cfa0f7e446bdbd4ca
    # begin
    #   inreplace "#{proc_plugins}/processing_r/processing/provider.py" do |s|
    #   s.gsub! "'Activate'), False))", "'Activate'), True))"
    #   end
    #   puts "R RAlgorithmProvider.py has been updated"
    #   rescue Utils::InreplaceError
    #   puts "R provider.py already updated"
    # end

    # WhiteboxTools
    begin
      whitebox="#{Formula["osgeo-whitebox-tools"].opt_bin}/whitebox_tools"
      inreplace "#{proc_plugins}/processing_whitebox/whiteboxProvider.py" do |s|
      s.gsub! "/usr/local/opt/whitebox-tools/bin/whitebox_tools", "#{whitebox}"
      end
      puts "Whitebox Tools whiteboxProvider.py has been updated"
      rescue Utils::InreplaceError
      puts "Whitebox Tools whiteboxProvider.py already updated"
    end

    # TauDEM
    begin
      taudem="#{Formula["osgeo-taudem"].opt_bin}"
      mpich="#{Formula["open-mpi"].opt_bin}"
      inreplace "#{proc_plugins}/processing_taudem/taudemProvider.py" do |s|
      s.gsub! "/usr/local/opt/taudem/bin", "#{taudem}"
      s.gsub! "/usr/local/opt/open-mpi/bin", "#{mpich}"
      end
      puts "TauDEM taudemProvider.py and has been updated"
      rescue Utils::InreplaceError
      puts "TauDEM taudemProvider.py already updated"
    end

    # LASTools
    begin
      lastools="#{Formula["osgeo-lastools"].opt_prefix}"
      inreplace "#{proc_plugins}/lastools/LAStoolsProvider.py" do |s|
      s.gsub! 'C:\LAStools', "#{lastools}"
      end
      puts "LAStools LAStoolsProvider.py has been updated"
      rescue Utils::InreplaceError
      puts "LAStools LAStoolsProvider.py already updated"
    end

    unless opts.include?("without-globe")
      osg = Formula["osgeo-openscenegraph"]
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

    # TODO: add for Py3
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

    # link python modules
    (prefix/"QGIS.app/Contents/Resources/python").install_symlink Dir["#{Formula["osgeo-qgis-res"].opt_libexec}/vendor/lib/python#{py_ver}/site-packages/*"]
    (prefix/"QGIS.app/Contents/Resources/python/PyQt5").install_symlink Dir["#{Formula["osgeo-sip"].opt_lib}/python#{py_ver}/site-packages/PyQt5/*"]
    ln_s "#{Formula["osgeo-sip"].opt_lib}/python#{py_ver}/site-packages/sipconfig.py", "#{prefix}/QGIS.app/Contents/Resources/python/sipconfig.py"
    ln_s "#{Formula["osgeo-sip"].opt_lib}/python#{py_ver}/site-packages/sipdistutils.py", "#{prefix}/QGIS.app/Contents/Resources/python/sipdistutils.py"
    (prefix/"QGIS.app/Contents/Resources/python/PyQt5").install_symlink Dir["#{Formula["osgeo-pyqt"].opt_lib}/python#{py_ver}/site-packages/PyQt5/*"]
    (prefix/"QGIS.app/Contents/Resources/python/PyQt5").install_symlink Dir["#{Formula["osgeo-pyqt-webkit"].opt_lib}/python#{py_ver}/site-packages/PyQt5/*"]
    (prefix/"QGIS.app/Contents/Resources/python/PyQt5").install_symlink Dir["#{Formula["osgeo-qscintilla2"].opt_lib}/python#{py_ver}/site-packages/PyQt5/*"]
    # (prefix/"QGIS.app/Contents/Resources/python").install_symlink Dir["#{Formula["osgeo-matplotlib"].opt_lib}/python#{py_ver}/site-packages/*"]
    # (prefix/"QGIS.app/Contents/Resources/python").install_symlink Dir["#{Formula["numpy"].opt_lib}/python#{py_ver}/site-packages/*"]
    # (prefix/"QGIS.app/Contents/Resources/python").install_symlink Dir["#{Formula["scipy"].opt_lib}/python#{py_ver}/site-packages/*"]
    (prefix/"QGIS.app/Contents/Resources/python").install_symlink Dir["#{Formula["osgeo-gdal-python"].opt_lib}/python#{py_ver}/site-packages/*"]

    # fix ImportError: No module named site for gdal_*.py
    mkdir "#{prefix}/QGIS.app/Contents/MacOS/bin"
    (prefix/"QGIS.app/Contents/MacOS/bin").install_symlink Dir["#{Formula["osgeo-gdal-python"].opt_bin}/*"]
    (prefix/"QGIS.app/Contents/MacOS/bin").install_symlink Dir["#{Formula["osgeo-gdal"].opt_bin}/*"]
    (prefix/"QGIS.app/Contents/Frameworks").install_symlink Dir["#{Formula["qt"].opt_frameworks}/*"]
    (prefix/"QGIS.app/Contents/Frameworks").install_symlink Dir["#{Formula["python"].opt_frameworks}/*"]

    ln_s "#{prefix}/QGIS.app/Contents/MacOS/lib", "#{prefix}/QGIS.app/Contents/MacOS/bin"
    ln_s "#{prefix}/QGIS.app/Contents/Frameworks", "#{prefix}/QGIS.app/Contents/MacOS"
    ln_s "#{Formula["python"].opt_bin}/python#{py_ver}", "#{prefix}/QGIS.app/Contents/MacOS/bin/python3"
    ln_s "#{Formula["python"].opt_bin}/python#{py_ver}", "#{prefix}/QGIS.app/Contents/MacOS/bin/python"
  end

  def caveats
    s = <<~EOS
      \nQGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in \e[32mQGIS.app\e[0m:

        \e[32m#{opt_prefix}/QGIS.app\e[0m

      You may also symlink \e[32mQGIS.app\e[0m into \e[32m/Applications\e[0m or \e[32m~/Applications\e[0m:

        \e[32mln -Fs `find $(brew --prefix) -name "QGIS.app"` /Applications/QGIS.app\e[0m

      To directly run the \e[32m`QGIS.app/Contents/MacOS/QGIS`\e[0m binary use the wrapper
      script pre-defined with Homebrew prefix environment variables:

        \e[32m#{opt_bin}/#{name}\e[0m

      If you need QGIS to appear in Spotlight, create and run the following script:

        \e[32m#!/usr/bin/env bash\e[0m

        \e[32mqgis_location=$(find $(brew --prefix)/Cellar/osgeo-qgis/ -name "3.*" -print -quit)/QGIS.app\e[0m
        \e[32mosascript -e 'tell application "Finder"' -e 'make new alias to file (posix file "'$qgis_location'") at (posix file "/Applications")' -e 'end tell'\e[0m

        https://github.com/OSGeo/homebrew-osgeo4mac/issues/607#issuecomment-455905926

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching \e[32mQGIS.app\e[0m
            bundle they are not.

      For standalone Python 3 development, set the following environment variable:

        \e[32mexport PYTHONPATH=#{python_site_packages}:#{qgis_site_packages}:#{qgis_python_packages}:#{gdal_python_packages}:$PYTHONPATH\e[0m

    EOS

    if build.with?("isolation")
      s += <<~EOS
        \033[31mQGIS built with isolation enabled. This allows it to coexist with other types of installations
        of QGIS on your Mac. However, on versions >= 2.0.1, this also means Python modules installed in the
        *system* Python will NOT be available to Python processes within QGIS.app.\e[0m

      EOS
    end

    s += <<~EOS

      You installed LAStools!

      If you will use Wine to have more features:

      \n1 - Download \e[32mhttp://lastools.org/download/LAStools.zip\e[0m and unzip LASTools.
          Remember where you unzipped it.

      2 - Start QGIS. Select \e[32mProcessing/Options.\e[0m
          In the Providers section scroll to “LASTools”

          \033[31mLASTools folder:\e[0m \e[32mLASTools directory\e[0m (unzipped)
          \033[31mWine Folder:\e[0m \e[32m#{Formula["wine"].opt_bin}\e[0m\n
    EOS

    s += <<~EOS
      If you have built GRASS 7 for the Processing plugin set the following in QGIS

        \e[32mProcessing -> Options: Providers -> GRASS GIS 7 commands -> GRASS 7 folder\e[0m

        to \e[32m#{HOMEBREW_PREFIX}/opt/osgeo-grass/grass-base\e[0m

    EOS

    s += <<~EOS
      QGIS plugins may need extra Python modules to function. Most can be installed
      with \e[32mpip\e[0m in a Terminal:

          \e[32mpip3 install modulename\e[0m

      If you want to upgrade modules, add the \e[32m-U\e[0m option:

          \e[32mpip3 install -U modulename\e[0m

    EOS

    s += <<~EOS

      Activate plugins

        \e[32mManage and Install Plugins -> Installed ->  Plugin name\e[0m (click its checkbox)

    EOS
    s
  end

  test do
    output = `#{bin}/#{name.to_s} --help 2>&1` # why does help go to stderr?
    assert_match /^QGIS is a user friendly/, output
  end

  private

  def majmin_ver
    grass_version = "#{Formula["osgeo-grass"].version}"
    ver_split = grass_version.to_s.split(".")
    ver_split[0] + ver_split[1]
  end

  # def brewed_openscenegraph?
  #   Formula["osgeo-openscenegraph"].opt_prefix.exist?
  # end

  # def brewed_osgqt?
  #   Formula["osgeo-osgqt"].opt_prefix.exist?
  # end

  # def brewed_osgearth?
  #   Formula["osgeo-osgearth"].opt_prefix.exist?
  # end

  def brewed_oracle?
    Formula["osgeo-oracle-client-sdk"].opt_prefix.exist?
  end

  def brewed_python?
    Formula["python"].linked_keg.exist?
  end

  def python_exec
    if brewed_python?
      "#{Formula["python"].opt_bin}/python3"
    else
      py_exec = `which python3`.strip
      raise if py_exec == ""
      py_exec
    end
  end

  def py_ver
    `#{python_exec} -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end

  def python_prefix
    `#{python_exec} -c 'import sys;print(sys.prefix)'`.strip
  end

  def qgis_python_packages
    "#{opt_prefix}/QGIS.app/Contents/Resources/python"
  end

  def qgis_site_packages
    "#{opt_lib}/python#{py_ver}/site-packages"
  end

  def python_site_packages
    "#{HOMEBREW_PREFIX}/opt/lib/python#{py_ver}/site-packages"
  end

  def gdal_python_packages
    "#{Formula["osgeo-gdal-python"].opt_lib}/python#{py_ver}/site-packages"
  end

  def gdal_python_opt_bin
    "#{Formula["osgeo-gdal-python"].opt_bin}"
  end

  def gdal_opt_bin
    "#{Formula["osgeo-gdal"].opt_bin}"
  end
end

__END__

--- a/cmake/FindQsci.cmake
+++ b/cmake/FindQsci.cmake
@@ -21,16 +21,20 @@
   SET(QSCI_FOUND TRUE)
 ELSE(EXISTS QSCI_MOD_VERSION_STR)

-  FIND_FILE(_find_qsci_py FindQsci.py PATHS ${CMAKE_MODULE_PATH})
+  # FIND_FILE(_find_qsci_py FindQsci.py PATHS ${CMAKE_MODULE_PATH})

   SET(QSCI_VER 5)

-  EXECUTE_PROCESS(COMMAND ${PYTHON_EXECUTABLE} ${_find_qsci_py} ${QSCI_VER} OUTPUT_VARIABLE qsci_ver)
+  # EXECUTE_PROCESS(COMMAND ${PYTHON_EXECUTABLE} ${_find_qsci_py} ${QSCI_VER} OUTPUT_VARIABLE qsci_ver)

   IF(qsci_ver)
     STRING(REGEX REPLACE "^qsci_version_str:([^\n]+).*$" "\\1" QSCI_MOD_VERSION_STR ${qsci_ver})
     SET(QSCI_FOUND TRUE)
   ENDIF(qsci_ver)
+
+  SET(QSCI_FOUND TRUE)
+  SET(QSCI_MOD_VERSION_STR 2.11.1)
+

   IF(QSCI_FOUND)
     FIND_PATH(QSCI_SIP_DIR

--- a/cmake/FindPyQt5.py
+++ b/cmake/FindPyQt5.py
@@ -39,7 +39,7 @@
     import os.path
     import sys
     cfg = sipconfig.Configuration()
-    sip_dir = cfg.default_sip_dir
+    sip_dir = "HOMEBREW_PREFIX/share/sip"
     if sys.platform.startswith('freebsd'):
         py_version = str(sys.version_info.major) + str(sys.version_info.minor)
         sip_dir = sip_dir.replace(py_version, '')

--- a/cmake/FindPyQt5.cmake
+++ b/cmake/FindPyQt5.cmake
@@ -37,9 +37,7 @@
     STRING(REGEX REPLACE ".*\npyqt_version_num:([^\n]+).*$" "\\1" PYQT5_VERSION_NUM ${pyqt_config})
     STRING(REGEX REPLACE ".*\npyqt_mod_dir:([^\n]+).*$" "\\1" PYQT5_MOD_DIR ${pyqt_config})
     STRING(REGEX REPLACE ".*\npyqt_sip_dir:([^\n]+).*$" "\\1" PYQT5_SIP_DIR ${pyqt_config})
-    IF(EXISTS ${PYQT5_SIP_DIR}/Qt5)
-      SET(PYQT5_SIP_DIR ${PYQT5_SIP_DIR}/Qt5)
-    ENDIF(EXISTS ${PYQT5_SIP_DIR}/Qt5)
+    SET(PYQT5_SIP_DIR ${PYQT5_SIP_DIR})
     STRING(REGEX REPLACE ".*\npyqt_sip_flags:([^\n]+).*$" "\\1" PYQT5_SIP_FLAGS ${pyqt_config})
     STRING(REGEX REPLACE ".*\npyqt_bin_dir:([^\n]+).*$" "\\1" PYQT5_BIN_DIR ${pyqt_config})
     STRING(REGEX REPLACE ".*\npyqt_sip_module:([^\n]+).*$" "\\1" PYQT5_SIP_IMPORT ${pyqt_config})


# --- a/src/core/processing/qgsprocessingfeedback.cpp
# +++ b/src/core/processing/qgsprocessingfeedback.cpp
# @@ -22,6 +22,9 @@
#  #if PROJ_VERSION_MAJOR > 4
#  #include <proj.h>
#  #else
# +#ifndef ACCEPT_USE_OF_DEPRECATED_PROJ_API_H
# +#define ACCEPT_USE_OF_DEPRECATED_PROJ_API_H
# +#endif
#  #include <proj_api.h>
#  #endif
#
# @@ -124,4 +127,3 @@ void QgsProcessingMultiStepFeedback::updateOverallProgress( double progress )
#    double currentAlgorithmProgress = progress / mChildSteps;
#    mFeedback->setProgress( baseProgress + currentAlgorithmProgress );
#  }
# -


--- a/src/app/qgisapp.cpp
+++ b/src/app/qgisapp.cpp
@@ -509,7 +509,7 @@
   if ( QgsProject::instance()->isDirty() )
     caption.prepend( '*' );

-  caption += QgisApp::tr( "QGIS" );
+  caption += QgisApp::tr( "OSGeo4Mac - QGIS" );

   if ( Qgis::QGIS_VERSION.endsWith( QLatin1String( "Master" ) ) )
   {


--- a/src/ui/qgsabout.ui
+++ b/src/ui/qgsabout.ui
@@ -244,6 +244,16 @@
               </size>
              </property>
             </spacer>
+           </item>
+           <item>
+            <widget class="QLabel" name="label_osgeo">
+             <property name="text">
+              <string>OSGeo4Mac Team / Maintainer: @fjperini - Collaborator: @luispuerto</string>
+             </property>
+             <property name="alignment">
+              <set>Qt::AlignCenter</set>
+             </property>
+            </widget>
            </item>
            <item>
             <widget class="QLabel" name="label_3">
