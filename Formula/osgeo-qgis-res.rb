################################################################################
# Maintainer: FJ Perini @fjperini
# Collaborator: Luis Puerto @luispuerto
################################################################################

class OsgeoQgisRes < Formula
  include Language::Python::Virtualenv
  desc "Resources for QGIS"
  homepage "https://www.qgis.org"
  url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  version "3.8.0"

  # revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "8e9ab749b7f1aa6d8e423803ac837038cc46c1c63e9b5c6581fa80068a7fc0c4" => :mojave
    sha256 "8e9ab749b7f1aa6d8e423803ac837038cc46c1c63e9b5c6581fa80068a7fc0c4" => :high_sierra
    sha256 "550e3697860fc778b23e93b38246da65181afef57872f4616e11ee29cb38be7c" => :sierra
  end

  option "with-pg10", "Build with PostgreSQL 10 client"

  depends_on "pkg-config" => :build
  depends_on "gcc" => :build # for gfortran # numpy
  depends_on "python" => :build
  depends_on "swig" => :build
  depends_on "lapack"
  depends_on "openblas"
  depends_on "cython"
  depends_on "libyaml" # yaml
  depends_on "tcl-tk" # six
  depends_on "openjpeg" # for Pillow
  depends_on "zlib" # for Pillow
  depends_on "freetype"

  depends_on "dbus"
  depends_on "glib"
  depends_on "qt"
  depends_on "osgeo-pyqt"

  # psycopg2
  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  depends_on "swig"
  depends_on "libagg"
  depends_on "libpng"
  depends_on "openssl"
  depends_on "libssh"
  depends_on "qhull"
  depends_on "ghostscript"
  depends_on "cairo"
  depends_on "py3cairo"
  depends_on "libsvg-cairo"
  depends_on "librsvg"
  depends_on "svg2pdf"
  depends_on "gtk+3"
  depends_on "pygobject3"
  depends_on "pygobject"
  depends_on "pygtk"
  depends_on "wxpython"
  depends_on "ffmpeg"
  depends_on "imagemagick"

  depends_on "numpy"
  depends_on "scipy"
  depends_on "osgeo-matplotlib"

  depends_on "osgeo-gdal-python" # osgeo-gdal: for Fiona
  depends_on "spatialindex" # for Rtree
  depends_on "hdf5" # for h5py
  depends_on "unixodbc" # for pyodbc
  depends_on "pyside" # for pyqtgraph / required llvm
  depends_on "freetds" # for pymssql

  # R with more support
  # https://github.com/adamhsparks/setup_macOS_for_R
  # rpy2 requires finding R
  # unless Formula["sethrfore/r-srf/r"].linked_keg.exist?
  depends_on "r"
  # end

  # for rpy2
  depends_on "gettext"
  depends_on "readline"
  depends_on "pcre"
  depends_on "xz"
  depends_on "bzip2"
  depends_on "libiconv"
  depends_on "icu4c"

  # pyqgis_startup.py
  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)

  # resource "pyproj" do
  #   url "https://files.pythonhosted.org/packages/93/48/956b9dcdddfcedb1705839280e02cbfeb2861ed5d7f59241210530867d5b/numpy-1.16.3.zip"
  #   sha256 "78a6f89da87eeb48014ec652a65c4ffde370c036d780a995edaeb121d3625621"
  # end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/93/48/956b9dcdddfcedb1705839280e02cbfeb2861ed5d7f59241210530867d5b/numpy-1.16.3.zip"
    sha256 "78a6f89da87eeb48014ec652a65c4ffde370c036d780a995edaeb121d3625621"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/cb/97/361c8c6ceb3eb765371a702ea873ff2fe112fa40073e7d2b8199db8eb56e/scipy-1.3.0.tar.gz"
    sha256 "c3bb4bd2aca82fb498247deeac12265921fe231502a6bc6edea3ee7fe6c40a7a"
  end

  resource "matplotlib" do
    url "https://files.pythonhosted.org/packages/26/04/8b381d5b166508cc258632b225adbafec49bbe69aa9a4fa1f1b461428313/matplotlib-3.0.3.tar.gz"
    sha256 "e1d33589e32f482d0a7d1957bf473d43341115d40d33f578dad44432e47df7b7"
  end

  def install
    # install python environment
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")

    py_ver = Language::Python.major_minor_version "#{libexec}/vendor/bin/python3"

    # fix pip._vendor.pep517.wrappers.BackendUnavailable  // use pip<19.0.0
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip", "wheel"

    res_r = ['rpy2', 'sphinxcontrib-websupport']

    res_r.each do |r|
      venv.pip_install r
    end

    # fix ModuleNotFoundError: No module named 'pip.req'
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip==9.0.3", "wheel"
    venv.pip_install "pyRscript"

    # fix pip._vendor.pep517.wrappers.BackendUnavailable
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel"

    res_required = ['requests', 'six', 'future', 'Sphinx', 'setuptools-scm', 'chardet', 'idna', 'urllib3', 'PySocks', 'Pillow', 'cycler', \
      'kiwisolver', 'tornado', 'Unidecode', 'pyparsing', 'MarkupSafe', 'nose', 'Cython', 'python-dateutil', 'pytz', 'Jinja2', 'OWSLib', \
      'psycopg2', 'Pygments', 'PyYAML', "dbus-python", "PyOpenGL", 'certifi', 'funcsigs', 'coverage', 'mock', 'pbr', 'termcolor', 'oauthlib', 'pyOpenSSL', 'httplib2']

    res_required.each do |r|
        venv.pip_install r
    end

    resource("numpy").stage do
      openblas = Formula["openblas"].opt_prefix
      ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
      ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

      config = <<~EOS
        [openblas]
        libraries = openblas
        library_dirs = #{openblas}/lib
        include_dirs = #{openblas}/include
      EOS

      Pathname("site.cfg").write config

      system "#{libexec}/vendor/bin/python3", "setup.py",
        "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
        "install", "--prefix=#{libexec}/vendor",
        "--single-version-externally-managed", "--record=installed.txt"
    end

    resource("scipy").stage do
      openblas = Formula["openblas"].opt_prefix
      ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
      ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

      config = <<~EOS
        [DEFAULT]
        library_dirs = #{HOMEBREW_PREFIX}/lib
        include_dirs = #{HOMEBREW_PREFIX}/include
        [openblas]
        libraries = openblas
        library_dirs = #{openblas}/lib
        include_dirs = #{openblas}/include
      EOS

      Pathname("site.cfg").write config

      system "#{libexec}/vendor/bin/python3", "setup.py",
        "build", "--fcompiler=gnu95",
        "install", "--prefix=#{libexec}/vendor"
      # cleanup leftover .pyc files from previous installs which can cause problems
      # see https://github.com/Homebrew/homebrew-python/issues/185#issuecomment-67534979
      rm_f Dir["#{libexec}/vendor/lib/python*.*/site-packages/scipy/**/*.pyc"]
    end

    resource("matplotlib").stage do
      if DevelopmentTools.clang_build_version >= 900
        ENV.delete "SDKROOT"
        ENV.delete "HOMEBREW_SDKROOT"
      end

      inreplace "setupext.py",
                "'darwin': ['/usr/local/'",
                "'darwin': ['#{HOMEBREW_PREFIX}'"

      system "#{libexec}/vendor/bin/python3", "setup.py",
        "install", "--prefix=#{libexec}/vendor"
    end

    res_optional = ['argparse', 'asn1crypto', 'atlas', 'backports.functools_lru_cache', 'beautifulsoup4', 'blosc', 'bottleneck', \
      'cffi', 'cryptography', 'decorator', 'descartes', 'ExifRead', 'Fiona', 'geopandas', 'geopy', 'geos', 'gitdb', 'gitdb2', 'GitPython', \
      'gnm', 'h5py', 'ipython', 'ipython_genutils', 'jsonschema', 'jupyter', 'jupyter_core', 'lidar', 'lxml', 'mpmath', 'nbformat', \
      'networkx', 'nltk', 'nose2', 'numexpr', 'olefile', 'openpyxl', 'palettable', 'pandas', 'pandas_oracle', 'pandas-datareader', 'pgi', \
      'plotly', 'ply', 'pubsub', 'py-postgresql', 'py2oracle', 'pycparser', 'pymssql', 'PyMySQL', 'pyodbc', 'PyPubSub', \
      'pyqtgraph', 'Pyro4', 'PySAL', 'pytest', 'pytils', 'qtpy', 'retrying', 'Rtree', 'seaborn', 'Shapely', 'simplejson', 'smmap', \
      'smmap2', 'sqlalchemy', 'statsmodels', 'subprocess32', 'sympy', 'test', 'tools', 'traitlets', 'whitebox', 'xlrd', 'xlsxwriter', 'xlwt']

    # others: gmt-python, pytables
    res_optional.each do |r|
      venv.pip_install r
    end

    # 'scikit-learn': It seems that scikit-learn cannot be built with OpenMP support
    # 'pyproj': version 2.0.0 supports & requires PROJ 6
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel", "scikit-learn==0.19.2", "pyproj==1.9.6"

    # upgrade pip
    # system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip", "wheel"

    cp_r "#{buildpath}/pyqgis_startup.py", "#{libexec}"
  end

  def caveats
      s = <<~EOS

        This formula was created to have more Python modules and save time using the generated bottle.

        It is not necessary to build each time a new version or revision of the QGIS formula is generated.

        It will only be updated if necessary, although you can choose to update modules if you wish,

        just remember that you will need to build QGIS again.

      EOS
    s
  end

  test do
    #  TODO
  end
end
