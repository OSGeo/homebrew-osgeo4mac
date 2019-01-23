require File.expand_path("../../Requirements/grass_requirements",
                         Pathname.new(__FILE__).realpath)

class Grass7 < Formula
  include Language::Python::Virtualenv

  desc "Geographic Resources Analysis Support System"
  homepage "https://grass.osgeo.org/"

  revision 1

  # svn: E230001: Server SSL certificate verification failed: issuer is not trusted
  # head "https://svn.osgeo.org/grass/grass/trunk", :using => :svn
  # head "svn://svn.osgeo.org/grass/grass/trunk"
  head "https://github.com/GRASS-GIS/grass-ci.git", :branch => "master"

  stable do
    url "https://grass.osgeo.org/grass76/source/grass-7.6.0.tar.gz"
    sha256 "07628f83ad59ba6d9d097cdc91c490efaf5b1d57bc7ee1fc2709183162741b6a"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # no_symbolic_links
    patch :DATA
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "95954620adc0aafef7dbbceb89414a69b70172b409486f2dffbccb51be6d2cdc" => :mojave
    sha256 "95954620adc0aafef7dbbceb89414a69b70172b409486f2dffbccb51be6d2cdc" => :high_sierra
    sha256 "95954620adc0aafef7dbbceb89414a69b70172b409486f2dffbccb51be6d2cdc" => :sierra
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available."
  option "with-aqua", "Build with experimental Aqua GUI backend."
  option "with-app", "Build GRASS.app Package"
  option "with-liblas", "Build with LibLAS-with-GDAL2 support"
  option "with-netcdf", "Build with NetCDF support"
  option "with-zstd", "Build with zstd support"
  option "with-postgresql", "Build with PostgreSQL support"
  option "with-mysql", "Build with MySQL support"
  option "with-pthread", "Build with PThread support"
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
  depends_on "gdal2"
  depends_on "readline"
  depends_on "lapack"
  depends_on "openblas"
  depends_on "bzip2"
  depends_on "zlib"
  depends_on "unixodbc"
  depends_on "wxmac"
  depends_on "wxpython"
  depends_on "subversion" # for g.extension
  depends_on "avce00" # avcimport
  depends_on "openjpeg" # for Pillow

  depends_on :x11 if build.without? "aqua" # needs to find at least X11/include/GL/gl.h

  depends_on UnlinkedGRASS7

  # optional dependencies
  depends_on "netcdf" => :optional
  depends_on "liblas-gdal2" if build.with? "liblas"
  depends_on "zstd" => :optional
  depends_on "mysql" => :optional
  depends_on "postgresql" => :optional
  depends_on "libpq" => :optional
  depends_on "lbzip2" => :optional
  depends_on "libredwg" if build.with? "opendwg"
  depends_on "ffmpeg" => :optional
  depends_on "r" => :optional
  # depends_on "pdal" => :optional
  # depends_on "libomp" if build.with? "openmp"


  # matplotlib
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "pygobject"
  depends_on "pyqt"
  depends_on "numpy"
  depends_on "scipy"
  depends_on "brewsci/bio/matplotlib"

  # other dependencies

  depends_on "ffmpeg2theora" => :optional
  depends_on "ffmpegthumbnailer" => :optional
  depends_on "libav" => :optional
  depends_on "jasper" => :optional
  depends_on "wget" => :optional
  depends_on "dateutils" => :optional
  depends_on "gsl" => :optional
  depends_on "ncurses" => :optional
  depends_on "gdbm" => :optional
  depends_on "mesa" => :optional
  depends_on "mesalib-glw" => :optional
  depends_on "openmotif" => :optional

  depends_on "gpsbabel" => :optional
  depends_on "gdal2-python" => :optional
  depends_on "byacc" => :optional # yacc
  depends_on "desktop-file-utils" => :optional
  depends_on "fontconfig" => :optional
  depends_on "netpbm" => :optional # mpeg_encode or ppmtompeg
  depends_on "lesstif" => :optional
  depends_on "openssl" => :optional
  depends_on "swig" => :optional
  depends_on "libjpeg-turbo" => :optional
  depends_on "cfitsio" => :optional
  depends_on "imagemagick" => :optional
  depends_on "xz" => :optional # lzma
  depends_on "gd" => :optional

  # depends_on "mariadb-connector-c" => :optional
  # depends_on "mariadb" => :optional

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
  end

  def majmin_ver
    ver_split = version.to_s.split(".")
    ver_split[0] + ver_split[1]
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/37/1b/b25507861991beeade31473868463dad0e58b1978c209de27384ae541b0b/setuptools-40.6.3.zip"
    sha256 "3b474dad69c49f0d2d86696b68105f3a6f195f7ab655af12ef9a9c326d2b08f8"
  end

  resource "pip" do
    url "https://files.pythonhosted.org/packages/45/ae/8a0ad77defb7cc903f09e551d88b443304a9bd6e6f124e75c0fbbf6de8f7/pip-18.1.tar.gz"
    sha256 "c0a292bd977ef590379a3f05d7b7f65135487b67470f6281289a94e015650ea1"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/d8/55/221a530d66bf78e72996453d1e2dedef526063546e131d70bed548d80588/wheel-0.32.3.tar.gz"
    sha256 "029703bf514e16c8271c3821806a1c171220cc5bdd325cbf4e7da1e056a01db6"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/1b/e1/1118d60e9946e4e77872b69c58bc2f28448ec02c99a2ce456cd1a272c5fd/Pillow-5.3.0.tar.gz"
    sha256 "2ea3517cd5779843de8a759c2349a3cd8d3893e03ab47053b66d5ec6f8bc4f93"
  end

  resource "ply" do
    url "http://www.dabeaz.com/ply/ply-3.11.tar.gz"
    sha256 "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"
  end

  resource "argparse" do
    url "https://files.pythonhosted.org/packages/18/dd/e617cfc3f6210ae183374cd9f6a26b20514bbb5a792af97949c5aacddf0f/argparse-1.4.0.tar.gz"
    sha256 "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"
  end

  # error: pip._vendor.pep517.wrappers.BackendUnavailable
  # resource "python-dateutil" do
  #   url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
  #   sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  # end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  resource "PyOpenGL" do
    url "https://files.pythonhosted.org/packages/ce/33/ef0e3b40a3f4cbfcfb93511652673fb19d07bafac0611f01f6237d1978ed/PyOpenGL-3.1.0.zip"
    sha256 "efa4e39a49b906ccbe66758812ca81ced13a6f26931ab2ba2dba2750c016c0d0"
  end

  resource "psycopg2" do
    url "https://files.pythonhosted.org/packages/c0/07/93573b97ed61b6fb907c8439bf58f09957564cf7c39612cef36c547e68c6/psycopg2-2.7.6.1.tar.gz"
    sha256 "27959abe64ca1fc6d8cd11a71a1f421d8287831a3262bd4cacd43bbf43cc3c82"
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
    url "https://files.pythonhosted.org/packages/e6/78/6e7b5af12c12bdf38ca9bfe863fcaf53dc10430a312d0324e76c1e5ca426/tornado-5.1.1.tar.gz"
    sha256 "4e5158d97583502a7e2739951553cbd88a72076f152b4b11b64b9a10c4c49409"
  end

  resource "cairocffi" do
    url "https://files.pythonhosted.org/packages/62/be/ad4d422b6f38d99b09ad6d046ab725e8ccac5fefd9ca256ca35a80dbf3c6/cairocffi-0.9.0.tar.gz"
    sha256 "15386c3a9e08823d6826c4491eaccc7b7254b1dc587a3b9ce60c350c3f990337"
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
    url "https://files.pythonhosted.org/packages/04/b6/d7faa70a3e3eac39f943cc6a6a64ce378259677de516bd899dd9eb8f9b32/numpy-1.16.0.zip"
    sha256 "cb189bd98b2e7ac02df389b6212846ab20661f4bafe16b5a70a6f1728c1cc7cb"
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
    # venv.pip_install resources

    # noinspection RubyLiteralArrayInspection
    args = [
      "--with-cxx",
      "--enable-shared",
      "--enable-largefile",
      "--with-nls",
      "--with-python=#{libexec}/vendor/bin/python-config",
      "--with-includes=#{HOMEBREW_PREFIX}/include",
      "--with-libs=#{HOMEBREW_PREFIX}/LIB",
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
      "--with-gdal=#{Formula["gdal2"].opt_bin}/gdal-config",
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
    args << "--with-tcltk" if build.with? "tcl-tk"

    args << "--with-liblas=#{Formula["liblas-gdal2"].opt_bin}/liblas-config" if build.with? "liblas"

    if build.with? "netcdf"
      args << "--with-netcdf=#{Formula["netcdf"].opt_bin}/nc-config"
    end

    if build.with? "zstd"
      args << "--with-zstd"
      args << "--with-zstd-includes=#{Formula["zstd"].opt_include}"
      args << "--with-zstd-libs=#{Formula["zstd"].opt_lib}"
    end

    if build.with? "postgresql"
      args << "--with-postgres"
      args << "--with-postgres-includes=#{Formula["postgres"].opt_include}"
      args << "--with-postgres-libs=#{Formula["postgres"].opt_lib}"
    end

    if build.with? "mysql"
      args << "--with-mysql"
      args << "--with-mysql-includes=#{Formula["mysql"].opt_include}/mysql"
      args << "--with-mysql-libs=#{Formula["mysql"].opt_lib}"
    end

    if build.with? "pthread"
      args << "--with-pthread"
      args << "--with-pthread-includes=#{Formula["boost"].opt_include}/boost/thread"
      args << "--with-pthread-libs=#{Formula["boost"].opt_lib}"
    end

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
      # args << "--with-opengl"
      args << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
      # args << "--with-opengl-libs=" # GL
      # args << "--with-opengl-framework="
    # end

    # Enable Aqua GUI, instead of X11
    args << "--with-opengl#{build.with?("aqua") ? "aqua" : ""}"

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
