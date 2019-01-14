class UnlinkedQGIS3 < Requirement
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

class Qgis3 < Formula
  include Language::Python::Virtualenv

  desc "Open Source Geographic Information System"
  homepage "https://www.qgis.org"
  url "https://github.com/qgis/QGIS.git",
    :branch => "release-3_4",
    :commit => "5364afe45cf00277a9de804ab33273b0661491bb"
  version "3.4.3"

  revision 2

  head "https://github.com/qgis/QGIS.git", :branch => "master"

  patch :DATA

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "cac047c5a647c608adb276f1a29d795ac8853485f21fa344d4fc992b2f69bb68" => :mojave
    sha256 "cac047c5a647c608adb276f1a29d795ac8853485f21fa344d4fc992b2f69bb68" => :high_sierra
    sha256 "cac047c5a647c608adb276f1a29d795ac8853485f21fa344d4fc992b2f69bb68" => :sierra
  end

  def pour_bottle?
    brewed_python?
  end

  option "without-ninja", "Disable use of ninja CMake generator"
  option "without-pyqt5-webkit", "Build without webkit python bindings"
  option "with-isolation", "Isolate .app's environment to HOMEBREW_PREFIX, to coexist with other QGIS installs"
  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "with-grass", "Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-orfeo", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga", "Build extra Saga GIS (LTS) for Processing plugin"
  option "with-qspatialite", "Build QSpatialite Qt database driver"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"
  option "with-3d", "Build with 3D Map View panel"
  # option "with-globe", "Build with Globe plugin, based upon osgEarth"
  # option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"

  depends_on UnlinkedQGIS3
  # depends_on Python

  # core qgis
  depends_on "cmake" => :build
  depends_on "ninja" => [:build, :recommended]
  depends_on "gsl" => :build
  depends_on "sip" => :build
  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "pkg-config" => :build
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
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on "postgresql" => :recommended
  depends_on "libpq"
  depends_on "curl"
  depends_on "libzip"
  depends_on "libtasn1"
  depends_on "hicolor-icon-theme"
  depends_on "libiconv"
  depends_on "geos"
  depends_on "libspatialite"
  depends_on "postgis2"
  depends_on "openssl"
  # depends_on "osgqt"
  depends_on "poppler"
  depends_on "gnu-sed"
  depends_on "exiv2"
  depends_on "liblas" => :optional
  depends_on "netcdf" => :optional
  depends_on "pdal" => :optional
  depends_on "openvpn" => :optional
  depends_on "szip" => :optional
  depends_on "hdf5" => :optional
  depends_on "scipy"

  if build.with? "server"
    depends_on "fcgi"
    depends_on "spawn-fcgi"
    depends_on "lighttpd"
  end

  # matplotlib
  depends_on "numpy"
  depends_on "brewsci/bio/matplotlib"

  # core providers
  depends_on "gdal2-python"

  depends_on "oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with?("grass") || (HOMEBREW_PREFIX/"opt/grass7").exist?
    depends_on "grass7"
    depends_on "gettext"
  end

  # # Not until osgearth is Qt5-ready
  # if build.with? "globe"
  #   # this is pretty borked with OS X >= 10.10+
  #   depends_on "open-scene-graph"
  #   depends_on "brewsci/science/osgearth"
  # end

  depends_on "gpsbabel" => :optional

  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)
  # TODO: what to do for Py3 and pyspatialite?
  depends_on "pyspatialite" # for DB Manager
  # depends_on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `grass` above
  depends_on "orfeo6" => :optional

  if build.with?("r")
    unless Formula["r"].opt_prefix.exist?
      depends_on "r"
    end
  end
  depends_on "saga-gis-lts" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)
  resource "pyqgis-startup" do
    url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
    sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
    version "2.14.0"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/41/b6/4f0cefba47656583217acd6cd797bc2db1fede0d53090fdc28ad2c8e0716/certifi-2018.10.15.tar.gz"
    sha256 "6d58c986d22b038c8c0df30d639f23a3e6d172a05c3583e766f4c0b785c0986a"
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
    url "https://files.pythonhosted.org/packages/cc/9c/fd05b20753b0c8a94c225e77c21dfa04a32c9fdbf54001b313bbd0092820/OWSLib-0.17.0.tar.gz"
    sha256 "ac43839c238ae427d6112709c489decb12218f02d5032ca729e5de7557b5a2df"
  end

  # dependence for pyproj
  resource "cython" do
    url "https://files.pythonhosted.org/packages/f0/66/6309291b19b498b672817bd237caec787d1b18013ee659f17b1ec5844887/Cython-0.29.tar.gz"
    sha256 "94916d1ede67682638d3cc0feb10648ff14dc51fb7a7f147f4fedce78eaaea97"
  end

  # fix for Python3.7
  resource "pyproj" do
    url "https://github.com/jswhit/pyproj.git",
      :branch => "master",
      :commit => "263e283bce209ec7a6e4517828a31839545f2e8a"
    version "1.9.6"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
    sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/cd/71/ae99fc3df1b1c5267d37ef2c51b7d79c44ba8a5e37b48e3ca93b4d74d98b/pytz-2018.7.tar.gz"
    sha256 "31cb35c89bd7d333cd32c5f278fca91b523b0834369e757f4c5641ea252236ca"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/40/35/298c36d839547b50822985a2cf0611b3b978a5ab7a5af5562b8ebe3e1369/requests-2.20.1.tar.gz"
    sha256 "ea881206e59f41dbd0bd445437d792e43906703fff75ca8ff43ccdb11f33f263"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/a5/74/05ffd00b4b5c08306939c485869f5dc40cbc27357195b0a98b18e4c48893/urllib3-1.24.tar.gz"
    sha256 "41c3db2fc01e5b907288010dec72f9d0a74e37d6994e6eb56849f59fea2265ae"
  end

  resource "coverage" do
    url "https://files.pythonhosted.org/packages/fb/af/ce7b0fe063ee0142786ee53ad6197979491ce0785567b6d8be751d2069e8/coverage-4.5.2.tar.gz"
    sha256 "ab235d9fe64833f12d1334d29b558aacedfbca2356dfb9691f2d0d38a8a7bfb4"
  end

  resource "funcsigs" do
    url "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"
    sha256 "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"
  end

  resource "future" do
    url "https://files.pythonhosted.org/packages/85/aa/ba2e24dcb889d7e98733f87515d80b3512418b80ba79d82d2ddcd43fadf3/future-0.17.0.tar.gz"
    sha256 "eb6d4df04f1fb538c99f69c9a28b255d1ee4e825d479b9c62fc38c0cf38065a4"
  end

  resource "mock" do
    url "https://files.pythonhosted.org/packages/0c/53/014354fc93c591ccc4abff12c473ad565a2eb24dcd82490fae33dbf2539f/mock-2.0.0.tar.gz"
    sha256 "b158b6df76edd239b8208d481dc46b6afd45a846b7812ff0ce58971cf5bc8bba"
  end

  resource "nose2" do
    url "https://files.pythonhosted.org/packages/1b/c5/d5fcd60f5bf8af1e320fde832d7965933581a9b21b0d1b29bbe2208f4403/nose2-0.8.0.tar.gz"
    sha256 "9052f2b46807b63d9bdf68e0768da1f8386368889b50043fd5d0889c470258f3"
  end

  resource "pbr" do
    url "https://files.pythonhosted.org/packages/33/07/6e68a96ff240a0e7bb1f6e21093532386a98a82d56512e1e3da6d125f7aa/pbr-5.1.1.tar.gz"
    sha256 "f59d71442f9ece3dffc17bc36575768e1ee9967756e6b6535f0ee1f0054c3d68"
  end

  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/c0/07/93573b97ed61b6fb907c8439bf58f09957564cf7c39612cef36c547e68c6/psycopg2-2.7.6.1.tar.gz"
    sha256 "27959abe64ca1fc6d8cd11a71a1f421d8287831a3262bd4cacd43bbf43cc3c82"
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

  resource "termcolor" do
    url "https://files.pythonhosted.org/packages/8a/48/a76be51647d0eb9f10e2a4511bf3ffb8cc1e6b14e9e4fab46173aa79f981/termcolor-1.1.0.tar.gz"
    sha256 "1d6d69ce66211143803fbc56652b41d73b4a400a2891d7bf7a1cdf4c02de613b"
  end

  resource "oauthlib" do
    url "https://files.pythonhosted.org/packages/df/5f/3f4aae7b28db87ddef18afed3b71921e531ca288dc604eb981e9ec9f8853/oauthlib-2.1.0.tar.gz"
    sha256 "ac35665a61c1685c56336bda97d5eefa246f1202618a1d6f34fccb1bdd404162"
  end

  resource "pyOpenSSL" do
    url "https://files.pythonhosted.org/packages/9b/7c/ee600b2a9304d260d96044ab5c5e57aa489755b92bbeb4c0803f9504f480/pyOpenSSL-18.0.0.tar.gz"
    sha256 "6488f1423b00f73b7ad5167885312bb0ce410d3312eb212393795b53c8caa580"
  end

  resource "httplib2" do
    url "https://files.pythonhosted.org/packages/fd/ce/aa4a385e3e9fd351737fd2b07edaa56e7a730448465aceda6b35086a0d9b/httplib2-0.11.3.tar.gz"
    sha256 "e71daed9a0e6373642db61166fa70beecc9bf04383477f84671348c02a04cbdf"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2d/80/1809de155bad674b494248bcfca0e49eb4c5d8bee58f26fe7a0dd45029e2/numpy-1.15.4.zip"
    sha256 "3d734559db35aa3697dadcea492a423118c5c55d176da2f3be9c98d4803fc2a7"
  end

  # R Provider Plugin
  resource "r-app" do
    url "https://github.com/north-road/qgis-processing-r.git",
      :branch => "master",
      :commit => "ebbfa9e6a243608415468ea3254a1a740bc2006c"
    version "0.0.3"
  end

  # Orfeo Provider Plugin
  resource "otb" do
    url "https://gitlab.orfeo-toolbox.org/orfeotoolbox/qgis-otb-plugin.git",
      :branch => "master",
      :commit => "a1762b732f18a2dff9e92c44cf2f892f227b0f91"
    version "0.1"
  end

  # Patch: OTBAlgorithmProvider
  resource "OTBAlgorithmProvider" do
    url "https://gist.githubusercontent.com/fjperini/009a5dda278c1a10e0758865d149820c/raw/6aa94c089d69cb6e936a4c9ddbf52404af397395/OTBAlgorithmProvider.patch"
    sha256 "e46c68bb9123ade3d61b9e567133d38816d9c584b406c387e9fff7408a0c58c5"
  end

  # Patch: OTBUtils
  resource "OTBUtils" do
    url "https://gist.githubusercontent.com/fjperini/53f53daf78ab5e203fd81322ea5c3a2f/raw/6daa39316c3c5d4da34a5f6717e8fb93418fff85/OTBUtils.patch"
    sha256 "a52899872c696b6fbdd3e4a09327feb74880a199a0bda8356785806bc6de8057"
  end

  # Patch: RAlgorithmProvider
  resource "RAlgorithmProvider" do
    url "https://gist.githubusercontent.com/fjperini/bf9fbd1ac9cc2729994cf331baf7a439/raw/855d95c24d5f4df910f8f454cf6b82389f5de820/RAlgorithmProvider.patch"
    sha256 "254b0341c05f077dbcf67e29c14d77407a765a04d04524915c9443498a3f4343"
  end

  needs :cxx11

  def install
    ENV.cxx11

    printf "\n\033[31mIn case you have installed another version of Python (Anaconda, Miniconda or if you used the installer provided by python.org).\e[0m\n\n"

    printf "\e[0mIf the installation failed due to the problem reported in \e[32mhttps://github.com/OSGeo/homebrew-osgeo4mac/issues/520\e[0m\n\n"

    printf "Try after doing:\n\n"

    printf "    $ brew unlink python && brew link --force python\n\n"

    printf "    $ $PATH (Check that there is no other version)\n\n"

    printf "\033[31mThe installation will continue, but remember the above.\e[0m\n"

    30.downto(0) do |i|
        printf "#{'%02d'% i}."
        sleep 1
    end

    printf "\n\n"

    if build.with?("r") || brewed_r?
      printf "If you need R with more support (\e[32mserfore/r-srf\e[0m): \e[32mhttps://github.com/adamhsparks/setup_macOS_for_R\e[0m\n\n"
    end

    printf "\n"

    # we proceed to install the plugins as a first step,
    # to ensure that the patches are applied
    mkdir "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"

    if build.with?("orfeo") || brewed_orfeo6?
      resource("otb").stage do
        cp_r "./otb", "#{buildpath}/python/plugins/"
      end
      resource("OTBAlgorithmProvider").stage do
        cp_r "./OTBAlgorithmProvider.patch", "#{buildpath}"
      end
      resource("OTBUtils").stage do
        cp_r "./OTBUtils.patch", "#{buildpath}"
      end
      system "patch", "-p1", "-i", "#{buildpath}/OTBAlgorithmProvider.patch"
      system "patch", "-p1", "-i", "#{buildpath}/OTBUtils.patch"
      cp_r "#{buildpath}/python/plugins/otb", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"
    end

    if build.with?("r") || brewed_r?
      resource("r-app").stage do
        cp_r "./r", "#{buildpath}/python/plugins/"
      end
      resource("RAlgorithmProvider").stage do
        cp_r "./RAlgorithmProvider.patch", "#{buildpath}"
      end
      system "patch", "-p1", "-i", "#{buildpath}/RAlgorithmProvider.patch"
      cp_r "#{buildpath}/python/plugins/r", "#{prefix}/QGIS.app/Contents/Resources/python/plugins/"
    end

    # when gdal2-python.rb loaded, PYTHONPATH gets set to 2.7 site-packages...
    # clear it before calling any local python3 functions
    ENV["PYTHONPATH"] = nil
    if ARGV.debug?
      puts "python_exec: #{python_exec}"
      puts "py_ver: #{py_ver}"
      puts "brewed_python?: #{brewed_python?}"
      puts "python_site_packages: #{python_site_packages}"
      puts "python_prefix: #{python_prefix}"
      puts "qgis_python_packages: #{qgis_python_packages}"
      puts "gdal_python_packages: #{gdal_python_packages}"
      puts "gdal_python_opt_bin: #{gdal_python_opt_bin}"
      puts "gdal_opt_bin: #{gdal_opt_bin}"
    end

    # install python environment
    venv = virtualenv_create(libexec/'vendor', "#{HOMEBREW_PREFIX}/opt/python/bin/python3")
    res = resources.map(&:name).to_set - %w[pyqgis-startup r-app otb OTBAlgorithmProvider OTBUtils RAlgorithmProvider]
    res.each do |r|
      venv.pip_install resource(r)
    end

    # set bundling level back to 0 (the default in all versions prior to 1.8.0)
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
      inreplace "external/qspatialite/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s
    end
    if build.with? "oracle"
      mkdir lib/"qt/plugins/sqldrivers"
      inreplace "src/providers/oracle/ocispatial/CMakeLists.txt",
                "${QT_PLUGINS_DIR}/sqldrivers", lib/"qt/plugins/sqldrivers".to_s
    end

    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override

    cmake_prefixes = %w[
      qt
      qt5-webkit
      pyqt5-webkit
      qscintilla2
      qwt
      qwtpolar
      qca
      qtkeychain
      gdal2
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

    qwt_fw = Formula["qwt"].opt_lib/"qwt.framework"
    qwtpolar_fw = Formula["qwtpolar"].opt_lib/"qwtpolar.framework"
    qca_fw = Formula["qca"].opt_lib/"qca-qt5.framework"
    args += %W[
      -DBISON_EXECUTABLE=#{Formula["bison"].opt_bin}/bison
      -DEXPAT_INCLUDE_DIR=#{Formula["expat"].opt_include}
      -DEXPAT_LIBRARY=#{Formula["expat"].opt_lib}/libexpat.dylib
      -DFLEX_EXECUTABLE=#{Formula["flex"].opt_bin}/flex
      -DPROJ_INCLUDE_DIR=#{Formula["proj"].opt_include}
      -DPROJ_LIBRARY=#{Formula["proj"].opt_lib}/libproj.dylib
      -DQCA_INCLUDE_DIR=#{qca_fw}/Headers
      -DQCA_LIBRARY=#{qca_fw}/qca-qt5
      -DQWTPOLAR_INCLUDE_DIR=#{qwtpolar_fw}/Headers
      -DQWTPOLAR_LIBRARY=#{qwtpolar_fw}/qwtpolar
      -DQWT_INCLUDE_DIR=#{qwt_fw}/Headers
      -DQWT_LIBRARY=#{qwt_fw}/qwt
      -DSPATIALINDEX_INCLUDE_DIR=#{Formula["spatialindex"].opt_include}/spatialindex
      -DSPATIALINDEX_LIBRARY=#{Formula["spatialindex"].opt_lib}/libspatialindex.dylib
      -DSQLITE3_INCLUDE_DIR=#{Formula["sqlite"].opt_include}
      -DSQLITE3_LIBRARY=#{Formula["sqlite"].opt_lib}/libsqlite3.dylib
      -DLIBZIP_CONF_INCLUDE_DIR=#{Formula["libzip"].opt_lib}/pkgconfig
      -DLIBZIP_INCLUDE_DIR=#{Formula["libzip"].opt_include}
      -DLIBZIP_LIBRARY=#{Formula["libzip"].opt_lib}/libzip.dylib
      -DSPATIALITE_INCLUDE_DIR=#{Formula["libspatialite"].opt_include}
      -DSPATIALITE_LIBRARY=#{Formula["libspatialite"].opt_lib}/libspatialite.dylib
      -DQTKEYCHAIN_INCLUDE_DIR=#{Formula["qtkeychain"].opt_include}/qt5keychain
      -DQTKEYCHAIN_LIBRARY=#{Formula["qtkeychain"].opt_lib}/libqt5keychain.dylib
      -DLIBTASN1_INCLUDE_DIR=#{Formula["libtasn1"].opt_include}
      -DLIBTASN1_LIBRARY=#{Formula["libtasn1"].opt_lib}/libtasn1.dylib

      -DQSCINTILLA_INCLUDE_DIR=#{Formula["qscintilla2"].opt_include}
      -DQSCINTILLA_LIBRARY=#{Formula["qscintilla2"].opt_lib}/libqscintilla2_qt5.dylib
      -DQSCI_SIP_DIR=#{Formula["qscintilla2"].opt_share}/sip
      -DPYQT5_SIP_DIR=#{Formula["pyqt"].opt_share}/sip/Qt5

      -DPYRCC_PROGRAM=#{libexec}/vendor/bin/pyrcc5
      -DPYUIC_PROGRAM=#{libexec}/vendor/bin/pyuic5

      -DQT_LRELEASE_EXECUTABLE=#{Formula["qt"].opt_bin}/lrelease
      -DWITH_QTWEBKIT=TRUE
      -DQt5WebKitWidgets_DIR=#{Formula["qt5-webkit"].opt_lib}/cmake/Qt5WebKitWidgets
      -DQt5WebKit_DIR=#{Formula["qt5-webkit"].opt_lib}/cmake/Qt5WebKit

      -DENABLE_TESTS=FALSE
      -DENABLE_MODELTEST=FALSE
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_INSTALL_DEV=FALSE
      -DWITH_QSCIAPI=FALSE
      -DWITH_CUSTOM_WIDGETS=TRUE
      -DWITH_ASTYLE=FALSE
      -DWITH_GRASS=FALSE
    ]

    # args << "-DAPPLE_APPKIT_LIBRARY=#{ENV['HOME']}/Library/Frameworks/AppKit.framework"
    # args << "-DAPPLE_APPLICATIONSERVICES_LIBRARY=#{ENV['HOME']}/Library/Frameworks/ApplicationServices.framework"
    # args << "-DAPPLE_COREFOUNDATION_LIBRARY=#{ENV['HOME']}/Library/Frameworks/CoreFoundation.framework"
    # args << "-DAPPLE_IOKIT_LIBRARY=#{ENV['HOME']}/Library/Frameworks/IOKit.framework"

    # disable CCache
    args << "-DUSE_CCACHE=OFF"

    # By default bindings will be installed only to QGIS directory
    # Someone might want to install it to python site-packages directory
    # as otherwise user has to use PYTHONPATH environment variable to add
    # args << "-DWITH_BINDINGS=ON"

    # python Configuration
    args << "-DPYTHON_EXECUTABLE='#{`#{HOMEBREW_PREFIX}/opt/python/bin/python3 -c "import sys; print(sys.executable)"`.chomp}'"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = python_prefix if brewed_python?

    # handle custom site-packages for keg-only modules and packages
    ENV.append_path "PYTHONPATH", python_site_packages
    # ENV.append_path "PYTHONPATH", qgis_python_packages
    ENV.append_path "PYTHONPATH", lib/"python#{py_ver}/site-packages"

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

    args << "-DWITH_SERVER=#{build.with?("server") ? "TRUE" : "FALSE"}"
    if build.with? "server"
      args << "-DWITH_SERVER_PLUGINS=TRUE"
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
    #   if build.with? "globe"
    #     osg = Formula["open-scene-graph"]
    #     osgqt = Formula["osgqt"]
    #     opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
    #     # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
    #     args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    #     # args << "-DOSGEARTHANNOTATION_LIBRARY=#{osg.opt_lib}"
    #     # args << "-DOSGEARTHFEATURES_LIBRARY=#{osg.opt_lib}"
    #     # args << "-DOSGEARTHQT_LIBRARY=#{osg.opt_lib}"
    #     # args << "-DOSGEARTHSYMBOLOGY_LIBRARY=#{osg.opt_lib}"
    #     # args << "-DOSGEARTHUTIL_LIBRARY=#{osg.opt_lib}/libosgUtil.dylib"
    #     args << "-DOSGEARTH_INCLUDE_DIR=#{osg.opt_include}"
    #     args << "-DOSGEARTH_LIBRARY=#{osg.opt_lib}/libosg.dylib"
    #     args << "-DOSGQT_LIBRARY=#{osgqt.opt_lib}/libosgQt5.dylib"
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
    #   args << "-DOPTIONAL_QTWEBKIT=#{Formula["qt5-webkit"].opt_lib}/cmake/Qt5WebKitWidgets"
    # end

    # prefer opt_prefix for CMake modules that find versioned prefix by default
    # this keeps non-critical dependency upgrades from breaking QGIS linking
    args << "-DGDAL_CONFIG=#{Formula["gdal2"].opt_bin}gdal-config"
    args << "-DGDAL_INCLUDE_DIR=#{Formula["gdal2"].opt_include}"
    args << "-DGDAL_LIBRARY=#{Formula["gdal2"].opt_lib}/libgdal.dylib"
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

    ENV.prepend_path "PATH", libexec/"vendor/bin"

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
    dy_libs = [lib/"qt/plugins/designer/libqgis_customwidgets.dylib"]
    dy_libs << lib/"qt/plugins/sqldrivers/libqsqlspatialite.dylib" if build.with? "qspatialite"
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
              "org.qgis.qgis3", "org.qgis.qgis3-hb#{build.head? ? "-dev" : ""}"

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

    pths.insert(0, "#{opt_libexec}/vendor/bin")

    unless pths.include?(HOMEBREW_PREFIX/"bin")
      pths = pths.insert(0, HOMEBREW_PREFIX/"bin")
    end

    # set install's lib/python#{py_ver}/site-packages first, so app will work if unlinked
    pypths = %W[#{opt_lib}/python#{py_ver}/site-packages #{opt_libexec}/vendor/lib/python#{py_ver}/site-packages #{pypth}]

    pths.insert(0, gdal_opt_bin)
    pths.insert(0, gdal_python_opt_bin)
    pypths.insert(0, gdal_python_packages)

    # prepend qt based utils to PATH (reverse order)
    pths.insert(0, Formula["qca"].opt_bin.to_s)
    pths.insert(0, Formula["pyqt"].opt_bin.to_s)
    pths.insert(0, Formula["sip"].opt_bin.to_s)
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

    if opts.include?("with-grass") || brewed_grass7?
      # for core integration plugin support
      grass7 = Formula["grass7"]
      envars[:GRASS_PREFIX] = "#{grass7.opt_prefix}/grass-base"
      # envars[:GRASS_SH] = "/bin/sh"
      # envars[:GRASS_PROJSHARE] = "#{Formula["proj"].opt_share}"
      # envars[:GRASS_VERSION] = "7.4.3"
      # envars[:GRASS_LD_LIBRARY_PATH] = "#{Formula["grass7"].opt_prefix}/grass-#{grass_version}/lib"
      # envars[:GRASS_PERL] = "#{Formula["perl"].opt_bin}/perl"
      begin
        inreplace "#{proc_plugins_algs}/grass7/Grass7Utils.py",
                  "'/Applications/GRASS-7.{}.app/Contents/MacOS'.format(version)",
                  "'#{grass7.opt_prefix}/grass-base'"
        puts "GRASS 7 GrassUtils.py has been updated"
        rescue Utils::InreplaceError
        puts "GRASS 7 GrassUtils.py already updated"
      end
    end

    if opts.include?("with-orfeo") || brewed_orfeo6?
      orfeo6 = Formula["orfeo6"]
      # envars[:QGIS_PLUGINPATH] = "#{orfeo6.opt_prefix}"
      begin
        inreplace "#{proc_plugins}/otb/OTBUtils.py" do |s|
        # default geoid path
        # try to replace first, so it fails (if already done) before global replaces
        s.sub! "OTB_GEOID_FILE) or ''", "OTB_GEOID_FILE) or '#{orfeo6.opt_libexec}/default_geoid/egm96.grd'"
        # default bin and lib path
        s.gsub! "/usr/local/bin", orfeo6.opt_bin.to_s
        s.gsub! "/usr/local/lib", orfeo6.opt_lib.to_s
        end
        puts "ORFEO 6 OTBUtils.py has been updated"
        rescue Utils::InreplaceError
        puts "ORFEO 6 OTBUtils.py already updated"
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

      For standalone Python3 development, set the following environment variable:
        export PYTHONPATH=#{qgis_python_packages}:#{gdal_python_packages}:#{python_site_packages}:$PYTHONPATH

    EOS

    if build.with? "isolation"
      s += <<~EOS
        QGIS built with isolation enabled. This allows it to coexist with other
        types of installations of QGIS on your Mac. However, on versions >= 2.0.1,
        this also means Python modules installed in the *system* Python will NOT
        be available to Python processes within QGIS.app.

      EOS
    end

    if build.with?("orfeo") || ("r")
      s += <<~EOS

        Activate plugin
        Manage and Install Plugins -> Installed ->  Plugin name (click its checkbox)

      EOS
    end


    s += <<~EOS
      QGIS plugins may need extra Python modules to function. Most can be installed with pip in a Terminal:

          pip3 install modulename

      If you want to upgrade modules, add the -U option:

          pip3 install -U modulename

    EOS

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

  def brewed_orfeo6?
    Formula["orfeo6"].opt_prefix.exist?
  end

  def brewed_r?
    Formula["r"].opt_prefix.exist?
  end

  def brewed_python?
    Formula["python"].linked_keg.exist?
  end

  def python_exec
    if brewed_python?
      libexec/"vendor/bin/python3"
    else
      py_exec = `which python3`.strip
      raise if py_exec == ""
      py_exec
    end
  end

  def py_ver
    `#{python_exec} -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end

  def python_site_packages
    libexec/"vendor/lib/python#{py_ver}/site-packages"
  end

  def python_prefix
    `#{python_exec} -c 'import sys;print(sys.prefix)'`.strip
  end

  def qgis_python_packages
    opt_lib/"python#{py_ver}/site-packages".to_s
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
    `#{python_exec} -c 'import sys; sys.path.insert(1, "#{gdal_python_packages}"); import #{mod}'`.strip
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
+  SET(QSCI_MOD_VERSION_STR 2.10.4)
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
