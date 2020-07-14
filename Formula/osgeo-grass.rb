class OsgeoGrass < Formula
  include Language::Python::Virtualenv

  desc "Geographic Resources Analysis Support System"
  homepage "https://grass.osgeo.org/"

  revision 7

  # svn: E230001: Server SSL certificate verification failed: issuer is not trusted
  # head "https://svn.osgeo.org/grass/grass/trunk", :using => :svn
  # head "svn://svn.osgeo.org/grass/grass/trunk"
  # head "https://github.com/GRASS-GIS/grass-ci.git", :branch => "master"
  head "https://github.com/OSGeo/grass.git", :branch => "master"

  stable do
    #url "https://github.com/OSGeo/grass/archive/7.8.2.tar.gz"
    #sha256 "07b69e2fe0678bca29d9303a90eaf4a29dddcfa97fa92e056e214f0415629b6d"
    url "https://github.com/OSGeo/grass.git",
    :branch => "releasebranch_7_8",
    :commit => "8bcecc9a609bff0184519b124df17fb38e1195a5"
    version "7.8.3"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # no_symbolic_links
    patch :DATA
  end

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "a7f144c886435ab9c4fab9f3096882709f00b319d476648f42a145b3531de1a7" => :catalina
    sha256 "a7f144c886435ab9c4fab9f3096882709f00b319d476648f42a145b3531de1a7" => :mojave
    sha256 "a7f144c886435ab9c4fab9f3096882709f00b319d476648f42a145b3531de1a7" => :high_sierra
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available"
  option "with-aqua", "Build with experimental Aqua GUI backend"
  option "with-app", "Build GRASS.app Package"
  option "with-avce00", "Build with AVCE00 support: Make Arc/Info (binary) Vector Coverages appear as E00"
  option "with-pg11", "Build with PostgreSQL 11 client"
  option "with-mysql", "Build with MySQL client"
  option "with-others", "Build with other optional dependencies"
  # option "with-openmp", "Build with openmp support"
  # option "with-opendwg", "Build with OpenDWG support"
  # option "with-pdal", "Build with PDAL support" # Build - Error: /vector/v.in.pdal

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw" => :recommended
  depends_on "tcl-tk" => :recommended
  depends_on "python"
  depends_on "boost"
  depends_on "libiconv"
  depends_on "bison"
  depends_on "cairo"
  depends_on "flex"
  depends_on "freetype"
  depends_on "gettext"
  depends_on "ghostscript"
  depends_on "libtiff"
  depends_on "libpng"
  depends_on "sqlite"
  depends_on "regex-opt"
  depends_on "geos"
  depends_on "readline"
  depends_on "lapack"
  depends_on "openblas"
  depends_on "bzip2"
  depends_on "zlib"
  depends_on "unixodbc"
  depends_on "wxmac"
  depends_on "wxpython"
  depends_on "zstd"
  depends_on "lbzip2"
  depends_on "xz"
  depends_on "byacc" # yacc
  depends_on "subversion" # for g.extension
  depends_on "openjpeg" # for Pillow
  depends_on "osgeo-netcdf"
  depends_on "osgeo-proj"
  depends_on "osgeo-gdal"
  depends_on "osgeo-gdal-python"
  depends_on "osgeo-libgeotiff"

  # matplotlib
  depends_on "py3cairo"
  depends_on "pygobject3"
  # depends_on "pygobject" # Does not support Python 3, and needs pygtk which has been removed.
  depends_on "pyqt"
  depends_on "osgeo-six"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "osgeo-matplotlib"

  # optional dependencies
  #depends_on "osgeo-liblas"
  depends_on "mysql" if build.with? "mysql"
  #depends_on "r"
  depends_on "avce00" => :optional # avcimport
  # depends_on "libomp" if build.with? "openmp"
  # depends_on "osgeo-pdal"

  if build.with?("pg11")
    depends_on "osgeo-postgresql@11"
  else
    depends_on "osgeo-postgresql"
  end

  depends_on :x11 if build.without? "aqua" # needs to find at least X11/include/GL/gl.h

  # other dependencies
  if build.with? "others"
    depends_on "gpsbabel"
    depends_on "netpbm" # mpeg_encode or ppmtompeg
    depends_on "openssl"
    depends_on "swig"
    depends_on "ffmpeg"
    depends_on "ffmpeg2theora"
    depends_on "ffmpegthumbnailer"
    depends_on "libav"
    depends_on "jasper"
    depends_on "wget"
    depends_on "dateutils"
    depends_on "gsl"
    depends_on "ncurses"
    depends_on "gdbm"
    depends_on "mesa"
    depends_on "mesalib-glw"
    depends_on "desktop-file-utils"
    depends_on "fontconfig"
    depends_on "openmotif" # or lesstif
    depends_on "libjpeg-turbo"
    depends_on "cfitsio"
    depends_on "imagemagick"
    depends_on "gd"
    # depends_on "mariadb-connector-c"
    # depends_on "mariadb"
  end

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
  end

  def majmin_ver
    ver_split = version.to_s.split(".")
    ver_split[0] + ver_split[1]
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/42/3e/2464120172859e5d103e5500315fb5555b1e908c0dacc73d80d35a9480ca/setuptools-45.1.0.zip"
    sha256 "91f72d83602a6e5e4a9e4fe296e27185854038d7cbda49dcd7006c4d3b3b89d5"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/8e/76/66066b7bc71817238924c7e4b448abdb17eb0c92d645769c223f9ace478f/pip-20.0.2.tar.gz"
    sha256 "7db0c8ea4c7ea51c8049640e8e6e7fde949de672bfa4949920675563a5a6967f"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/75/28/521c6dc7fef23a68368efefdcd682f5b3d1d58c2b90b06dc1d0b805b51ae/wheel-0.34.2.tar.gz"
    sha256 "8788e9155fe14f54164c1b9eb0a319d98ef02c160725587ad60f14ddc57b6f96"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/39/47/f28067b187dd664d205f75b07dcc6e0e95703e134008a14814827eebcaab/Pillow-7.0.0.tar.gz"
    sha256 "4d9ed9a64095e031435af120d3c910148067087541131e82b3e8db302f4c8946"
  end

  resource "ply" do
    url "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "argparse" do
    url "https://files.pythonhosted.org/packages/18/dd/e617cfc3f6210ae183374cd9f6a26b20514bbb5a792af97949c5aacddf0f/argparse-1.4.0.tar.gz"
    sha256 "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/be/ed/5bbc91f03fa4c839c4c7360375da77f9659af5f7086b7a7bdda65771c8e0/python-dateutil-2.8.1.tar.gz"
    sha256 "73ebfe9dbf22e832286dafa60473e4cd239f8592f699aa5adaf10050e6e1823c"
  end

  # resource "six" do
  #   url "https://files.pythonhosted.org/packages/21/9f/b251f7f8a76dec1d6651be194dfba8fb8d7781d10ab3987190de8391d08e/six-1.14.0.tar.gz"
  #   sha256 "236bdbdce46e6e6a3d61a337c0f8b763ca1e8717c03b369e87a7ec7ce1319c0a"
  # end

  resource "PyOpenGL" do
    url "https://files.pythonhosted.org/packages/b8/73/31c8177f3d236e9a5424f7267659c70ccea604dab0585bfcd55828397746/PyOpenGL-3.1.5.tar.gz"
    sha256 "4107ba0d0390da5766a08c242cf0cf3404c377ed293c5f6d701e457c57ba3424"
  end

  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/84/d7/6a93c99b5ba4d4d22daa3928b983cec66df4536ca50b22ce5dcac65e4e71/psycopg2-2.8.4.tar.gz"
    sha256 "f898e5cc0a662a9e12bde6f931263a1bbd350cfb18e1d5336a12927851825bb6"
  end

  resource "termcolor" do
    url "https://files.pythonhosted.org/packages/8a/48/a76be51647d0eb9f10e2a4511bf3ffb8cc1e6b14e9e4fab46173aa79f981/termcolor-1.1.0.tar.gz"
    sha256 "1d6d69ce66211143803fbc56652b41d73b4a400a2891d7bf7a1cdf4c02de613b"
  end

  # for matplotlib

  resource "cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "kiwisolver" do
    url "https://files.pythonhosted.org/packages/16/e7/df58eb8868d183223692d2a62529a594f6414964a3ae93548467b146a24d/kiwisolver-1.1.0.tar.gz"
    sha256 "53eaed412477c836e1b9522c19858a8557d6e595077830146182225613b11a75"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/a2/56/0404c03c83cfcca229071d3c921d7d79ed385060bbe969fde3fd8f774ebd/pyparsing-2.4.6.tar.gz"
    sha256 "4c830582a84fb022400b85429791bc551f1f4871c33f23e44f353119e92f969f"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/82/c3/534ddba230bd4fbbd3b7a3d35f3341d014cca213f369a9940925e7e5f691/pytz-2019.3.tar.gz"
    sha256 "b02c06db6cf09c12dd25137e563b31700d3b80fcc4ad23abb7a315f2789819be"
  end

  # resource "tornado" do
  #   url "https://files.pythonhosted.org/packages/e6/78/6e7b5af12c12bdf38ca9bfe863fcaf53dc10430a312d0324e76c1e5ca426/tornado-5.1.1.tar.gz"
  #   sha256 "4e5158d97583502a7e2739951553cbd88a72076f152b4b11b64b9a10c4c49409"
  # end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/30/78/2d2823598496127b21423baffaa186b668f73cd91887fcef78b6eade136b/tornado-6.0.3.tar.gz"
    sha256 "c845db36ba616912074c5b1ee897f8e0124df269468f25e4fe21fe72f6edd7a9"
  end

  resource "cairocffi" do
    url "https://files.pythonhosted.org/packages/f7/99/b3a2c6393563ccbe081ffcceb359ec27a6227792c5169604c1bd8128031a/cairocffi-1.1.0.tar.gz"
    sha256 "f1c0c5878f74ac9ccb5d48b2601fcc75390c881ce476e79f4cfedd288b1b05db"
  end

  resource "subprocess32" do
    url "https://files.pythonhosted.org/packages/32/c8/564be4d12629b912ea431f1a50eb8b3b9d00f1a0b1ceff17f266be190007/subprocess32-3.5.4.tar.gz"
    sha256 "eb2937c80497978d181efa1b839ec2d9622cf9600a039a79d0e108d1f9aec79d"
  end

  resource "backports.functools_lru_cache" do
    url "https://files.pythonhosted.org/packages/ad/2e/aa84668861c3de458c5bcbfb9813f0e26434e2232d3e294469e96efac884/backports.functools_lru_cache-1.6.1.tar.gz"
    sha256 "8fde5f188da2d593bd5bc0be98d9abc46c95bb8a9dde93429570192ee6cc2d4a"
  end

  # resource "numpy" do
  #   url "https://files.pythonhosted.org/packages/40/de/0ea5092b8bfd2e3aa6fdbb2e499a9f9adf810992884d414defc1573dca3f/numpy-1.18.1.zip"
  #   sha256 "b6ff59cee96b454516e47e7721098e6ceebef435e3e21ac2d6c3b8b02628eb77"
  # end

  # python version >= 3.5 required
  # resource "scipy" do
  #   url "https://files.pythonhosted.org/packages/04/ab/e2eb3e3f90b9363040a3d885ccc5c79fe20c5b8a3caa8fe3bf47ff653260/scipy-1.4.1.tar.gz"
  #   sha256 "dee1bbf3a6c8f73b6b218cb28eed8dd13347ea2f87d572ce19b289d6fd3fbc59"
  # end

  # "error: no member named 'signbit' in the global namespace"
  # resource "matplotlib" do
  #   url "https://github.com/matplotlib/matplotlib/archive/v2.2.5.tar.gz"
  #   sha256 "75e9de4e4e47ae4cb23393e9df9431424d5034da77771d598ff14363d6a51dd1"
  # end

  # resource "matplotlib" do
  #   url "https://github.com/matplotlib/matplotlib/archive/v3.1.3.tar.gz"
  #   sha256 "6edfe021671fcad1bd6081c980c380cb3d66d00895eb8c3450fa3842c441d1d1"
  # end

  # resource "wxPython" do
  #   url "https://files.pythonhosted.org/packages/b9/8b/31267dd6d026a082faed35ec8d97522c0236f2e083bf15aff64d982215e1/wxPython-4.0.7.post2.tar.gz"
  #   sha256 "5a229e695b64f9864d30a5315e0c1e4ff5e02effede0a07f16e8d856737a0c4e"
  # end

  def install
    # Work around "error: no member named 'signbit' in the global namespace"
    # encountered when trying to detect boost regex in configure
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    # ENV.append "CPPFLAGS", ""
    # ENV.append "LDFLAGS", "-framework OpenCL"
    # ENV.append "CFLAGS", "-O2 -Werror=implicit-function-declaration"
    if build.with?("mysql")
      ENV["MYSQLD_CONFIG"] = "#{Formula["mysql"].opt_bin}/mysql_config"
    end

    # install python modules
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")
    res = resources.map(&:name).to_set # - %w[python-dateutil]

    # fix pip._vendor.pep517.wrappers.BackendUnavailable
    # system libexec/"vendor/bin/pip3", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel"
    # venv.pip_install_and_link "python-dateutil"

    res.each do |r|
      venv.pip_install resource(r)
    end

    # noinspection RubyLiteralArrayInspection
    args = [
      "--with-cxx",
      "--enable-shared",
      "--enable-largefile",
      "--with-nls",
      "--with-includes=#{HOMEBREW_PREFIX}/include",
      "--with-libs=#{HOMEBREW_PREFIX}/LIB",
      "--with-python=#{libexec}/vendor/bin/python-config",
      "--with-tcltk",
      "--with-netcdf=#{Formula["osgeo-netcdf"].opt_bin}/nc-config",
      "--with-zstd",
      "--with-zstd-includes=#{Formula["zstd"].opt_include}",
      "--with-zstd-libs=#{Formula["zstd"].opt_lib}",
      "--with-readline",
      "--with-readline-includes=#{Formula["readline"].opt_include}",
      "--with-readline-libs=#{Formula["readline"].opt_lib}",
      "--with-blas",
      "--with-blas-includes=#{Formula["openblas"].opt_include}",
      "--with-blas-libs=#{Formula["openblas"].opt_lib}",
      "--with-lapack",
      "--with-lapack-includes=#{Formula["lapack"].opt_include}",
      "--with-lapack-libs=#{Formula["lapack"].opt_lib}",
      "--with-geos=#{Formula["geos"].opt_bin}/geos-config",
      "--with-geos-includes=#{Formula["geos"].opt_include}",
      "--with-geos-libs=#{Formula["geos"].opt_lib}",
      "--with-odbc",
      "--with-odbc-includes=#{Formula["unixodbc"].opt_include}",
      "--with-odbc-libs=#{Formula["unixodbc"].opt_lib}",
      "--with-gdal=#{Formula["osgeo-gdal"].opt_bin}/gdal-config",
      "--with-zlib-includes=#{Formula["zlib"].opt_include}",
      "--with-zlib-libs=#{Formula["zlib"].opt_lib}",
      "--with-bzlib",
      "--with-bzlib-includes=#{Formula["bzip2"].opt_include}",
      "--with-bzlib-libs=#{Formula["bzip2"].opt_lib}",
      "--with-cairo",
      "--with-cairo-includes=#{Formula["cairo"].opt_include}/cairo",
      "--with-cairo-libs=#{Formula["cairo"].opt_lib}",
      "--with-cairo-ldflags=-lfontconfig",
      "--with-freetype",
      "--with-freetype-includes=#{Formula["freetype"].opt_include}/freetype2",
      "--with-freetype-libs=#{Formula["freetype"].opt_lib}",
      # "--with-proj",
      "--with-proj-includes=#{Formula["osgeo-proj"].opt_include}",
      "--with-proj-libs=#{Formula["osgeo-proj"].opt_lib}",
      "--with-proj-share=#{Formula["osgeo-proj"].opt_share}/proj",
      "--with-tiff",
      "--with-tiff-includes=#{Formula["libtiff"].opt_include}",
      "--with-tiff-libs=#{Formula["libtiff"].opt_lib}",
      "--with-png",
      "--with-png-includes=#{Formula["libpng"].opt_include}",
      "--with-png-libs=#{Formula["libpng"].opt_lib}",
      "--with-regex",
      # "--with-regex-includes=#{Formula["regex-opt"].opt_lib}",
      # "--with-regex-libs=#{Formula["regex-opt"].opt_lib}",
      "--with-fftw",
      "--with-fftw-includes=#{Formula["fftw"].opt_include}",
      "--with-fftw-libs=#{Formula["fftw"].opt_lib}",
      "--with-sqlite",
      "--with-sqlite-includes=#{Formula["sqlite"].opt_include}",
      "--with-sqlite-libs=#{Formula["sqlite"].opt_lib}"
    ]

    # Disable some dependencies that don't build correctly on older version of MacOS
    args << "--without-fftw" if build.without? "fftw"

    #args << "--with-liblas=#{Formula["osgeo-liblas"].opt_bin}/liblas-config" # if build.with? "liblas"

    args << "--with-postgres"
    if build.with?("pg11")
      args << "--with-postgres-includes=#{Formula["osgeo-postgresql@11"].opt_include}"
      args << "--with-postgres-libs=#{Formula["osgeo-postgresql@11"].opt_lib}"
    else
      args << "--with-postgres-includes=#{Formula["osgeo-postgresql"].opt_include}"
      args << "--with-postgres-libs=#{Formula["osgeo-postgresql"].opt_lib}"
    end

    if build.with?("mysql")
      args << "--with-mysql"
      args << "--with-mysql-includes=#{Formula["mysql"].opt_include}/mysql"
      args << "--with-mysql-libs=#{Formula["mysql"].opt_lib}"
    end

    args << "--with-pthread"
    args << "--with-pthread-includes=#{Formula["boost"].opt_include}/boost/thread"
    args << "--with-pthread-libs=#{Formula["boost"].opt_lib}"

    # if build.with? "pdal"
    #   args << "--with-pdal=#{Formula["osgeo-pdal"].opt_bin}/pdal-config"
    # end

    # if build.with? "opendwg"
    #   args << "--with-opendwg"
    #   args << "--with-opendwg-includes="
    #   args << "--with-opendwg-libs="
    # end

    # if build.with? "openmp"
    #   # install openblas --with-openmp
    #   args << "--with-openmp"
    #   args << "--with-openmp-includes=#{Formula["libomp"].opt_include}"
    #   args << "--with-openmp-libs=#{Formula["libomp"].opt_lib}"
    # end

    # if build.with? "opencl"
    #   args << "--with-opencl"
    #   args << "--with-opencl-includes="
    #   args << "--with-opencl-libs="
    # end

    if MacOS.version >= :el_capitan
      # handle stripping of DYLD_* env vars by SIP when passed to utilities;
      # HOME env var is .brew_home during build, so it is still checked for lib
      ln_sf "#{buildpath}/dist.x86_64-apple-darwin#{`uname -r`.strip}/lib", ".brew_home/lib"
    end

    # NoMethodError: undefined method `prefer_64_bit?' for OS::Mac:Module
    # MacOS.prefer_64_bit? is deprecated! There is no replacement.
    # args << "--enable-64bit" if MacOS.prefer_64_bit?
    # args << "--with-macos-archs=#{MacOS.preferred_arch}"

    # unless MacOS::CLT.installed?
    # On Xcode-only systems (without the CLT), we have to help:
    args << "--with-macosx-sdk=#{MacOS.sdk_path}"
    args << "--with-macosx-archs=#{Hardware::CPU.arch}" # Hardware::CPU.universal_archs
    args << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
    # args << "--with-opengl-libs=" # GL
    # args << "--with-opengl-framework="
    # end

    # Enable Aqua GUI, instead of X11
    if build.with? "aqua"
      args.concat [
        "--with-opengl=aqua",
        "--without-glw",
        "--without-motif"
      ]
    end

    if headless?
      args << "--without-wxwidgets"
    else
      wx_paths = formula_site_packages "wxpython"
      ENV.prepend("PYTHONPATH", wx_paths, File::PATH_SEPARATOR) if wx_paths
      args << "--with-wxwidgets=#{Formula["wxmac"].opt_bin}/wx-config"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make", "-j", Hardware::CPU.cores, "GDAL_DYNAMIC=" # make and make install must be separate steps.
    system "make", "-j", Hardware::CPU.cores, "GDAL_DYNAMIC=", "install" # GDAL_DYNAMIC set to blank for r.external compatability
  end

  def post_install
    # ensure QGIS's Processing plugin recognizes install
    # 2.14.8+ and other newer QGIS versions may reference just grass.sh
    bin_grass = "#{bin}/grass#{majmin_ver}"
    ln_sf "#{bin_grass}", "#{prefix}/grass#{majmin_ver}/grass#{majmin_ver}.sh"
    ln_sf "#{bin_grass}", "#{prefix}/grass#{majmin_ver}/grass.sh"
    # link so settings in external apps don't need updated on grass version bump
    # in QGIS Processing options, GRASS folder = HOMEBREW_PREFIX/opt/grass7/grass-base
    ln_sf "grass#{majmin_ver}", "#{prefix}/grass-base"
    # Writes a wrapper env script and moves all files to the dst

    # ensure python3 is used
    # for some reason, in this build (v7.6.1_1), the script is not created.
    # bin.env_script_all_files("#{libexec}/bin", :GRASS_PYTHON => "python3")
    # for this reason we move the binary and create another that will call
    # this with the requirements mentioned above.
    mkdir "#{libexec}/bin"
    mv "#{bin}/grass#{majmin_ver}", "#{libexec}/bin/grass#{majmin_ver}"
    # And fix "ValueError: unknown locale: UTF-8"
    # if exist: rm "#{bin}/grass#{majmin_ver}"
    File.open("#{bin}/grass#{majmin_ver}", "w") { |file|
      file << '#!/bin/bash'
      file << "\n"
      file << "export LANG=en_US.UTF-8"
      file << "\n"
      file << "export LC_CTYPE=en_US.UTF-8"
      file << "\n"
      file << "export LC_ALL=en_US.UTF-8"
      file << "\n"
      file << "export GRASS_PREFIX=#{prefix}/grass-base"
      file << "\n"
      file << "export GRASS_SH=/bin/sh"
      file << "\n"
      file << "export GRASS_PROJSHARE=#{Formula["osgeo-proj"].opt_share}"
      file << "\n"
      file << "export GRASS_VERSION=#{version}"
      file << "\n"
      file << "export GRASS_LD_LIBRARY_PATH=#{prefix}/grass#{majmin_ver}/lib"
      file << "\n"
      # file << "export GRASS_PERL=#{Formula["perl"].opt_bin}/perl"
      # file << "\n"
      file << "export PROJ_LIB=#{Formula["osgeo-proj"].opt_lib}"
      file << "\n"
      file << "export GEOTIFF_CSV=#{Formula["osgeo-libgeotiff"].opt_share}/epsg_csv"
      file << "\n"
      file << "export GDAL_DATA=#{Formula["osgeo-gdal"].opt_share}/gdal"
      # file << "\n"
      # file << "export PYTHONHOME=#{Formula["python"].opt_frameworks}/Python.framework/Versions/#{py_ver}:$PYTHONHOME"
      # file << "export R_HOME=#{Formula["r"].opt_bin}/R:$R_HOME"
      # file << "export R_HOME=/Applications/RStudio.app/Contents/MacOS/RStudio:$R_HOME"
      # file << "export R_USER=USER_PROFILE/Documents"
      file << "\n"
      file << "GRASS_PYTHON=python3 exec #{libexec}/bin/grass#{majmin_ver} $@"
      # file << "GISBASE=#{HOMEBREW_PREFIX}/osgeo-grass"
      # file << "PATH=#{PATH}:#{GISBASE}/bin:#{GISBASE}/scripts"
      # file << "MANPATH=#{MANPATH}:#{GISBASE}/man"
    }
    chmod("+x", "#{bin}/grass#{majmin_ver}")
    chmod("+x", "#{libexec}/bin/grass#{majmin_ver}")

    # for "--enable-macosx-app"
    # mkdir - permission denied: /Library/GRASS
    if build.with? "app"
      ("#{prefix}/GRASS7.app/Contents/PkgInfo").write "APPLGRASS"
      mkdir "#{prefix}/GRASS7.app/Contents/Resources"
      cp_r "#{buildpath}/macosx/app/app.icns", "#{prefix}/GRASS7.app/Contents/Resources"

      config = <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>English</string>
          <key>CFBundleExecutable</key>
          <string>grass#{majmin_ver}</string>
          <key>CFBundleGetInfoString</key>
          <string>GRASS GIS #{version}</string>
          <key>CFBundleIconFile</key>
          <string>app.icns</string>
          <key>CFBundleIdentifier</key>
          <string>https://grass.osgeo.org/grass#{majmin_ver}/source/</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleShortVersionString</key>
          <string>GRASS GIS #{version}</string>
          <key>CFBundleSignature</key>
          <string>????</string>
          <key>CFBundleVersion</key>
          <string>#{version}</string>
          <key>NSMainNibFile</key>
          <string>MainMenu.nib</string>
          <key>NSPrincipalClass</key>
          <string>NSApplication</string>
          <key>CFBundleDocumentTypes</key>
          <array>
            <dict>
              <key>CFBundleTypeExtensions</key>
              <array>
                <string>****</string>
              </array>
              <key>CFBundleTypeName</key>
              <string>FolderType</string>
              <key>CFBundleTypeOSTypes</key>
              <array>
                <string>fold</string>
              </array>
              <key>CFBundleTypeRole</key>
              <string>Editor</string>
            </dict>
          </array>
        </dict>
        </plist>
      EOS

      ("#{prefix}/GRASS7.app/Contents/Info.plist").write config

      chdir "#{prefix}/GRASS7.app/Contents" do
        mkdir "MacOS" do
          ln_s "#{bin}/grass#{majmin_ver}", "grass#{majmin_ver}"
        end
      end
    end
  end

  def formula_site_packages(f)
    `#{Formula["python"].opt_bin}/python3 -c "import os, sys, site; sp1 = list(sys.path); site.addsitedir('#{Formula[f].opt_lib}/python3.7/site-packages'); print(os.pathsep.join([x for x in sys.path if x not in sp1]))"`.strip
  end

  def caveats
    s = <<~EOS

      If it is the case that you can change the shebang at the beginning of
      the script to enforce Python 3 usage.

        \e[32m#!/usr/bin/env python\e[0m

      Should be changed into

        \e[32m#!/usr/bin/env python3\e[0m

    EOS

    if headless?
      s += <<~EOS

      This build of GRASS has been compiled without the WxPython GUI.

      The command line tools remain fully functional.

      EOS
    end

    if build.with? "app"
      s += <<~EOS

      You may also symlink \e[32mGRASS.app\e[0m into \e[32m/Applications\e[0m or \e[32m~/Applications\e[0m:

        \e[32mln -Fs `find $(brew --prefix) -name "GRASS.app"` /Applications/GRASS.app\e[0m

      EOS
    end
    s
  end

  test do
    system bin/"grass#{majmin_ver}", "--version"
  end
end

__END__

--- a/configure
+++ b/configure
@@ -6894,7 +6894,7 @@
   ac_save_cflags="$CFLAGS"
   ac_save_cppflags="$CPPFLAGS"
   LIBS="$LIBS $LIBLAS_LIBS"
-  CFLAGS="$CFLAGS $LIBLAS_CFLAGS"
+  CFLAGS="$CFLAGS $LIBLAS_CFLAGS $LIBLAS_INC"
   CPPFLAGS="$CPPFLAGS $LIBLAS_INC"
   for ac_hdr in liblas/capi/liblas.h
 do


--- a/include/Make/Install.make
+++ b/include/Make/Install.make
@@ -114,11 +114,6 @@ real-install: | $(INST_DIR) $(UNIX_BIN)
 	-$(INSTALL) config.status $(INST_DIR)/config.status
 	-$(CHMOD) -R a+rX $(INST_DIR) 2>/dev/null

-ifneq ($(findstring darwin,$(ARCH)),)
-	@# enable OSX Help Viewer
-	@/bin/ln -sfh "$(INST_DIR)/docs/html" /Library/Documentation/Help/GRASS-$(GRASS_VERSION_MAJOR).$(GRASS_VERSION_MINOR)
-endif
-
 $(INST_DIR) $(UNIX_BIN):
 	$(MAKE_DIR_CMD) $@

--- a/macosx/app/build_html_user_index.sh
+++ b/macosx/app/build_html_user_index.sh
@@ -140,7 +140,6 @@ else
 #      echo "<tr><td valign=\"top\"><a href=\"$HTMLDIRG/$i\">$BASENAME</a></td> <td>$SHORTDESC</td></tr>" >> $FULLINDEX
       # make them local to user to simplify page links
       echo "<tr><td valign=\"top\"><a href=\"global_$i\">$BASENAME</a></td> <td>$SHORTDESC</td></tr>" >> $FULLINDEX
-      ln -sf "$HTMLDIRG/$i" global_$i
     done
   done
 fi
@@ -183,8 +182,3 @@ echo "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
 </html>" > $i.html
 done

-# add Help Viewer links in user docs folder
-
-mkdir -p $HOME/Library/Documentation/Help/
-ln -sfh ../../GRASS/$GRASS_MMVER/Modules/docs/html $HOME/Library/Documentation/Help/GRASS-$GRASS_MMVER-addon
-ln -sfh $GISBASE/docs/html $HOME/Library/Documentation/Help/GRASS-$GRASS_MMVER
