################################################################################
# Maintainer: FJ Perini @fjperini
# Collaborator: Nick Robison @nickrobison
# Collaborator: Luis Puerto @luispuerto
################################################################################

class QgisRes < Formula
  include Language::Python::Virtualenv
  desc "Resources for QGIS"
  homepage "https://www.qgis.org"
  url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  version "3.6.0"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 2
    sha256 "42e7563e1964134647321e0828896b1a722772a8da6dad3541c29411a144f0f0" => :mojave
    sha256 "42e7563e1964134647321e0828896b1a722772a8da6dad3541c29411a144f0f0" => :high_sierra
    sha256 "42e7563e1964134647321e0828896b1a722772a8da6dad3541c29411a144f0f0" => :sierra
  end

  # revision 1

  # option "with-complete", "Build with others modules"
  # option "with-r", "Build with modules referred to R"
  # option "with-r-sethrfore", "Build with modules referred to R (only if you use this version)"

  depends_on "pkg-config" => :build
  depends_on "gcc" => :build # for gfortran # numpy
  depends_on "python" => :build
  depends_on "swig" => :build
  depends_on "lapack"
  depends_on "openblas"
  depends_on "cython"
  depends_on "postgresql" # psycopg2
  depends_on "libyaml" # yaml
  depends_on "tcl-tk" # six
  depends_on "openjpeg" # for Pillow
  depends_on "zlib" # for Pillow
  depends_on "freetype"

  depends_on "dbus"
  depends_on "glib"
  depends_on "qt"
  depends_on "pyqt-qt5"

  # for rpy2
  # if build.with?("r#{"-sethrfore" if build.with? "r-sethrfore"}")
    depends_on "gettext"
    depends_on "readline"
    depends_on "pcre"
    depends_on "xz"
    depends_on "bzip2"
    depends_on "libiconv"
    depends_on "icu4c"
  # end

  # if build.with?("complete")
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
    depends_on "brewsci/bio/matplotlib"

    depends_on "gdal2-python" # gdal2: for Fiona
    depends_on "spatialindex" # for Rtree
    depends_on "hdf5" # for h5py
    depends_on "unixodbc" # for pyodbc
    depends_on "pyside" # for pyqtgraph / required llvm
    depends_on "freetds" # for pymssql
  # end

  # if build.with?("r")
    depends_on "r"
  # end

  # R with more support
  # https://github.com/adamhsparks/setup_macOS_for_R
  # fix: rpy2 requires finding R
  # if build.with?("r-sethrfore")
  #   depends_on "sethrfore/r-srf/r"
  # end

  # pyqgis_startup.py
  # TODO: add one for Py3 (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2b/26/07472b0de91851b6656cbc86e2f0d5d3a3128e7580f23295ef58b6862d6c/numpy-1.16.1.zip"
    sha256 "31d3fe5b673e99d33d70cfee2ea8fe8dccd60f265c3ed990873a88647e3dd288"
  end

  resource "scipy" do
    url "https://files.pythonhosted.org/packages/a9/b4/5598a706697d1e2929eaf7fe68898ef4bea76e4950b9efbe1ef396b8813a/scipy-1.2.1.tar.gz"
    sha256 "e085d1babcb419bbe58e2e805ac61924dac4ca45a07c9fa081144739e500aa3c"
  end

  # resource "matplotlib" do
  #   url "https://files.pythonhosted.org/packages/89/0c/653aec68e9cfb775c4fbae8f71011206e5e7fe4d60fcf01ea1a9d3bc957f/matplotlib-3.0.2.tar.gz"
  #   sha256 "c94b792af431f6adb6859eb218137acd9a35f4f7442cea57e4a59c54751c36af"
  # end

  def install
    # install python environment
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")

    py_ver = Language::Python.major_minor_version "#{libexec}/vendor/bin/python3"

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

    # resource("matplotlib").stage do
    #   if DevelopmentTools.clang_build_version >= 900
    #     ENV.delete "SDKROOT"
    #     ENV.delete "HOMEBREW_SDKROOT"
    #   end
    #
    #   inreplace "setupext.py",
    #             "'darwin': ['/usr/local/'",
    #             "'darwin': ['#{HOMEBREW_PREFIX}'"
    #
    #   system "#{libexec}/vendor/bin/python3", "setup.py",
    #     "install", "--prefix=#{libexec}/vendor"
    # end

    # if build.with?("complete")
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
    # end

    # if build.with?("r#{"-sethrfore" if build.with? "r-sethrfore"}")
      res_r = ['rpy2', 'sphinxcontrib-websupport']

      res_r.each do |r|
        venv.pip_install r
      end
      # fix ModuleNotFoundError: No module named 'pip.req'
      system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip==9.0.3", "wheel"
      venv.pip_install "pyRscript"
    # end

    # upgrade pip
    system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip", "wheel"

    cp_r "#{buildpath}/pyqgis_startup.py", "#{libexec}"
  end

  def caveats
      s = <<~EOS

        This formula was created to have more Python modules and save time using the generated bottle.

        It is not necessary to build each time a new version or revision of the QGIS formula is generated.

        It will only be updated if necessary, although you can choose to update modules if you wish,

        just remember that you will need to build QGIS again.

      EOS

    # if build.without?("r") && build.with?("r-sethrfore")
    #   s += <<~EOS
    #     You can use the \e[32m--with-r\e[0m flag to install modules associated with R.
    #
    #   EOS
    # end
    #
    # if build.with?("r")
    #   s += <<~EOS
    #     You can use the \e[32m--with-r-sethrfore\e[0m flag to install modules associated with R, with more support (only if you use this version).
    #
    #   EOS
    # end
    #
    # if build.without?("complete")
    #   s += <<~EOS
    #     You can use the \e[32m--with-complete\e[0m flag to install more modules.
    #
    #     \033[31mThis is highly recommended if you will install QGIS with optional support.\e[0m
    #
    #   EOS
    # end
    s
  end

  test do
    #  TODO
  end
end
