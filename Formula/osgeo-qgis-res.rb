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
  version "3.6.1"

  revision 1

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

  depends_on "gdal2-python" # gdal2: for Fiona
  depends_on "spatialindex" # for Rtree
  depends_on "hdf5" # for h5py
  depends_on "unixodbc" # for pyodbc
  depends_on "pyside" # for pyqtgraph / required llvm
  depends_on "freetds" # for pymssql

  # R with more support
  # https://github.com/adamhsparks/setup_macOS_for_R
  # rpy2 requires finding R
  unless Formula["sethrfore/r-srf/r"].linked_keg.exist?
    depends_on "r"
  end

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

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/cf/8d/6345b4f32b37945fedc1e027e83970005fc9c699068d2f566b82826515f2/numpy-1.16.2.zip"
    sha256 "6c692e3879dde0b67a9dc78f9bfb6f61c666b4562fd8619632d7043fb5b691b0"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/a9/b4/5598a706697d1e2929eaf7fe68898ef4bea76e4950b9efbe1ef396b8813a/scipy-1.2.1.tar.gz"
    sha256 "e085d1babcb419bbe58e2e805ac61924dac4ca45a07c9fa081144739e500aa3c"
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
      'kiwisolver', 'tornado', 'Unidecode', 'pyparsing', 'MarkupSafe', 'nose', 'Cython', 'python-dateutil', 'pyproj', 'pytz', 'Jinja2', 'OWSLib', \
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
      'pyqtgraph', 'Pyro4', 'PySAL', 'pytest', 'pytils', 'qtpy', 'retrying', 'Rtree', 'scikit-learn', 'seaborn', 'Shapely', 'simplejson', 'smmap', \
      'smmap2', 'sqlalchemy', 'statsmodels', 'subprocess32', 'sympy', 'test', 'tools', 'traitlets', 'whitebox', 'xlrd', 'xlsxwriter', 'xlwt']

    # others: gmt-python, pytables
    res_optional.each do |r|
      venv.pip_install r
    end

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
