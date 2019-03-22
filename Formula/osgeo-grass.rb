class OsgeoGrass < Formula
  include Language::Python::Virtualenv

  desc "Geographic Resources Analysis Support System"
  homepage "https://grass.osgeo.org/"

  # revision 1

  # svn: E230001: Server SSL certificate verification failed: issuer is not trusted
  # head "https://svn.osgeo.org/grass/grass/trunk", :using => :svn
  # head "svn://svn.osgeo.org/grass/grass/trunk"
  head "https://github.com/GRASS-GIS/grass-ci.git", :branch => "master"

  stable do
    url "https://grass.osgeo.org/grass76/source/grass-7.6.1.tar.gz"
    sha256 "07628f83ad59ba6d9d097cdc91c490efaf5b1d57bc7ee1fc2709183162741b6a"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # no_symbolic_links
    patch :DATA
  end
  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "d46769985f1e9d8159b8b2b02d4d6c9fdb2cd44d4b0c6ac291dbee3525323779" => :mojave
    sha256 "d46769985f1e9d8159b8b2b02d4d6c9fdb2cd44d4b0c6ac291dbee3525323779" => :high_sierra
    sha256 "57f13876bd9f9ae91ed65352b8a853a6c31f5e7b2159ad07359b2e058ce1c257" => :sierra
  end


  option "without-gui", "Build without WxPython interface. Command line tools still available"
  option "with-aqua", "Build with experimental Aqua GUI backend"
  option "with-app", "Build GRASS.app Package"
  option "with-avce00", "Build with AVCE00 support: Make Arc/Info (binary) Vector Coverages appear as E00"
  option "with-postgresql10", "Build with PostgreSQL 10 client"
  option "with-others", "Build with other optional dependencies"
  # option "with-r", "Build with R support"
  # option "with-r-sethrfore", "Build with R support (only if you are going to install with this version of R)"
  # option "with-liblas", "Build with LibLAS-with-GDAL2 support"
  # option "with-postgresql", "Build with PostgreSQL support"
  # option "with-mysql", "Build with MySQL support"
  # option "with-pthread", "Build with PThread support"
  # option "with-openmp", "Build with openmp support"
  # option "with-opendwg", "Build with OpenDWG support"
  # option "with-pdal", "Build with PDAL support" # Build - Error: /vector/v.in.pdal

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw" => :recommended
  depends_on "tcl-tk" => :recommended
  depends_on "python@2"
  depends_on "boost"
  depends_on "libiconv"
  depends_on "libgeotiff"
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
  depends_on "proj"
  depends_on "geos"
  depends_on "readline"
  depends_on "lapack"
  depends_on "openblas"
  depends_on "bzip2"
  depends_on "zlib"
  depends_on "unixodbc"
  depends_on "netcdf"
  depends_on "wxmac"
  depends_on "wxpython"
  depends_on "zstd"
  depends_on "lbzip2"
  depends_on "xz"
  depends_on "byacc" # yacc
  depends_on "subversion" # for g.extension
  depends_on "openjpeg" # for Pillow
  depends_on "osgeo-gdal"
  depends_on "osgeo-gdal-python"

  depends_on :x11 if build.without? "aqua" # needs to find at least X11/include/GL/gl.h

  # matplotlib
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "pygobject"
  depends_on "osgeo-pyqt"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "osgeo-matplotlib"

  # optional dependencies

  depends_on "osgeo-liblas" # if build.with? "liblas"

  depends_on "mysql" # if build.with? "mysql"

  if build.with?("postgresql10")
    depends_on "postgresql@10"
  else
    depends_on "postgresql"
  end

  depends_on "avce00" => :optional # avcimport

  # if build.with? "r"
  depends_on "r"
  # end

  # depends_on "pdal" => :optional
  # depends_on "libomp" if build.with? "openmp"

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
    url "https://files.pythonhosted.org/packages/c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0/setuptools-40.8.0.zip"
    sha256 "6e4eec90337e849ade7103723b9a99631c1f0d19990d6e8412dc42f5ae8b304d"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/36/fa/51ca4d57392e2f69397cd6e5af23da2a8d37884a605f9e3f2d3bfdc48397/pip-19.0.3.tar.gz"
    sha256 "6e6f197a1abfb45118dbb878b5c859a0edbdd33fd250100bc015b67fded4b9f2"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/b7/cf/1ea0f5b3ce55cacde1e84cdde6cee1ebaff51bd9a3e6c7ba4082199af6f6/wheel-0.33.1.tar.gz"
    sha256 "66a8fd76f28977bb664b098372daef2b27f60dc4d1688cfab7b37a09448f0e9d"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/3c/7e/443be24431324bd34d22dd9d11cc845d995bcd3b500676bcf23142756975/Pillow-5.4.1.tar.gz"
    sha256 "5233664eadfa342c639b9b9977190d64ad7aca4edc51a966394d7e08e7f38a9f"
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
    url "https://files.pythonhosted.org/packages/ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c/python-dateutil-2.8.0.tar.gz"
    sha256 "c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "PyOpenGL" do
    url "https://files.pythonhosted.org/packages/ce/33/ef0e3b40a3f4cbfcfb93511652673fb19d07bafac0611f01f6237d1978ed/PyOpenGL-3.1.0.zip"
    sha256 "efa4e39a49b906ccbe66758812ca81ced13a6f26931ab2ba2dba2750c016c0d0"
  end

  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/63/54/c039eb0f46f9a9406b59a638415c2012ad7be9b4b97bfddb1f48c280df3a/psycopg2-2.7.7.tar.gz"
    sha256 "f4526d078aedd5187d0508aa5f9a01eae6a48a470ed678406da94b4cd6524b7e"
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
    url "https://files.pythonhosted.org/packages/31/60/494fcce70d60a598c32ee00e71542e52e27c978e5f8219fae0d4ac6e2864/kiwisolver-1.0.1.tar.gz"
    sha256 "ce3be5d520b4d2c3e5eeb4cd2ef62b9b9ab8ac6b6fedbaa0e39cdb6f50644278"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc/pyparsing-2.3.1.tar.gz"
    sha256 "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"
    sha256 "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"
  end

  resource "tornado" do
    url "https://files.pythonhosted.org/packages/b1/7f/8109821ff9df1bf3519169e34646705c32ac13be6a4d51a79ed57f47686e/tornado-6.0.1.tar.gz"
    sha256 "de274c65f45f6656c375cdf1759dbf0bc52902a1e999d12a35eb13020a641a53"
  end

  resource "cairocffi" do
    url "https://files.pythonhosted.org/packages/0f/0f/7e21b5ddd31b610e46a879c0d21e222dd0fef428c1fc86bbd2bd57fed8a7/cairocffi-1.0.2.tar.gz"
    sha256 "01ac51ae12c4324ca5809ce270f9dd1b67f5166fe63bd3e497e9ea3ca91946ff"
  end

  resource "subprocess32" do
    url "https://files.pythonhosted.org/packages/be/2b/beeba583e9877e64db10b52a96915afc0feabf7144dcbf2a0d0ea68bf73d/subprocess32-3.5.3.tar.gz"
    sha256 "6bc82992316eef3ccff319b5033809801c0c3372709c5f6985299c88ac7225c3"
  end

  resource "backports.functools_lru_cache" do
    url "https://files.pythonhosted.org/packages/57/d4/156eb5fbb08d2e85ab0a632e2bebdad355798dece07d4752f66a8d02d1ea/backports.functools_lru_cache-1.5.tar.gz"
    sha256 "9d98697f088eb1b0fa451391f91afb5e3ebde16bbdb272819fd091151fda4f1a"
  end

  resource "numpy" do
    url "https://files.pythonhosted.org/packages/cf/8d/6345b4f32b37945fedc1e027e83970005fc9c699068d2f566b82826515f2/numpy-1.16.2.zip"
    sha256 "6c692e3879dde0b67a9dc78f9bfb6f61c666b4562fd8619632d7043fb5b691b0"
  end

  # "error: no member named 'signbit' in the global namespace"

  # resource "matplotlib" do
  #   url "https://github.com/matplotlib/matplotlib/archive/v2.2.3.tar.gz"
  #   sha256 "da5b804222864a8e854ed68f16dcbc8b2fa096537d84f879cc8289db368735c8"
  # end

  def install
    # Work around "error: no member named 'signbit' in the global namespace"
    # encountered when trying to detect boost regex in configure
    # if DevelopmentTools.clang_build_version >= 900
    #   ENV.delete "SDKROOT"
    #   ENV.delete "HOMEBREW_SDKROOT"
    # end

    # install python modules
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python@2"].opt_bin}/python2")
    res = resources.map(&:name).to_set # - %w[python-dateutil]

    # fix pip._vendor.pep517.wrappers.BackendUnavailable
    system libexec/"vendor/bin/pip2", "install", "--upgrade", "-v", "setuptools", "pip<19.0.0", "wheel"
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
      "--with-netcdf=#{Formula["netcdf"].opt_bin}/nc-config",
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
      "--with-proj-includes=#{Formula["proj"].opt_include}",
      "--with-proj-libs=#{Formula["proj"].opt_lib}",
      "--with-proj-share=#{Formula["proj"].opt_share}/proj",
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

    args << "--with-liblas=#{Formula["osgeo-liblas"].opt_bin}/liblas-config" # if build.with? "liblas"

    args << "--with-postgres"
    if build.with?("postgresql10")
      args << "--with-postgres-includes=#{Formula["postgres@10"].opt_include}"
      args << "--with-postgres-libs=#{Formula["postgres@10"].opt_lib}"
    else
      args << "--with-postgres-includes=#{Formula["postgres"].opt_include}"
      args << "--with-postgres-libs=#{Formula["postgres"].opt_lib}"
    end

    # if build.with? "mysql"
    args << "--with-mysql"
    args << "--with-mysql-includes=#{Formula["mysql"].opt_include}/mysql"
    args << "--with-mysql-libs=#{Formula["mysql"].opt_lib}"
    # end

    # if build.with? "pthread"
    args << "--with-pthread"
    args << "--with-pthread-includes=#{Formula["boost"].opt_include}/boost/thread"
    args << "--with-pthread-libs=#{Formula["boost"].opt_lib}"
    # end

    # if build.with? "opendwg"
    #   args << "--with-opendwg"
    #   args << "--with-opendwg-includes="
    #   args << "--with-opendwg-libs="
    # end

    # if build.with? "pdal"
    #   args << "--with-pdal=#{Formula["pdal"].opt_bin}/pdal-config"
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
      args << "--with-macosx-archs=#{MacOS.preferred_arch}" # Hardware::CPU.universal_archs
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

    # ensure QGIS's Processing plugin recognizes install
    # 2.14.8+ and other newer QGIS versions may reference just grass.sh
    bin_grass = "../bin/grass#{majmin_ver}"
    ln_sf bin_grass, prefix/"grass-#{version}/grass#{majmin_ver}.sh"
    ln_sf bin_grass, prefix/"grass-#{version}/grass.sh"
    # link so settings in external apps don't need updated on grass version bump
    # in QGIS Processing options, GRASS folder = HOMEBREW_PREFIX/opt/grass7/grass-base
    ln_sf "grass-#{version}", prefix/"grass-base"
    # ensure python2 is used
    bin.env_script_all_files(libexec/"bin", :GRASS_PYTHON => "python2")

    # fix "ValueError: unknown locale: UTF-8"
    rm "#{bin}/grass#{majmin_ver}"
    grass_version = "#{version}"
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
      file << "export GRASS_PROJSHARE=#{Formula["proj"].opt_share}"
      file << "\n"
      file << "export GRASS_VERSION=#{version}"
      file << "\n"
      file << "export GRASS_LD_LIBRARY_PATH=#{prefix}/grass-#{version}/lib"
      file << "\n"
      # file << "export GRASS_PERL=#{Formula["perl"].opt_bin}/perl"
      # file << "\n"
      file << "export PROJ_LIB=#{Formula["proj"].opt_lib}"
      file << "\n"
      file << "export GEOTIFF_CSV=#{Formula["libgeotiff"].opt_share}/epsg_csv"
      file << "\n"
      file << "export GDAL_DATA=#{Formula["osgeo-gdal"].opt_share}/gdal"
      # file << "\n"
      # file << "export PYTHONHOME=#{Formula["python"].opt_frameworks}/Python.framework/Versions/#{py_ver}:$PYTHONHOME"
      # file << "export R_HOME=#{Formula["r"].opt_bin}/R:$R_HOME"
      # file << "export R_HOME=/Applications/RStudio.app/Contents/MacOS/RStudio:$R_HOME"
      # file << "export R_USER=USER_PROFILE/Documents"
      file << "\n"
      file << "GRASS_PYTHON=python2 exec #{libexec}/bin/grass#{majmin_ver} $@"
    }

    # for "--enable-macosx-app"
    # mkdir - permission denied: /Library/GRASS
    if build.with? "app"
      (prefix/"GRASS7.app/Contents/PkgInfo").write "APPLGRASS"
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

      (prefix/"GRASS7.app/Contents/Info.plist").write config

      chdir "#{prefix}/GRASS7.app/Contents" do
        mkdir "MacOS" do
          ln_s "#{bin}/grass#{majmin_ver}", "grass#{majmin_ver}"
        end
      end
    end
  end

  def formula_site_packages(f)
    `#{Formula["python@2"].opt_bin}/python2 -c "import os, sys, site; sp1 = list(sys.path); site.addsitedir('#{Formula[f].opt_lib}/python2.7/site-packages'); print(os.pathsep.join([x for x in sys.path if x not in sp1]))"`.strip
  end

  def caveats
    s = <<~EOS

      If that is tha case you can change the shebang a the beginning of
      the script to enforce Python 2 usage.

        \e[32m#!/usr/bin/env python\e[0m

      Should be changed into

        \e[32m#!/usr/bin/env python2\e[0m

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
