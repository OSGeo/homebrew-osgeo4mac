class OsgeoMapnik < Formula
  include Language::Python::Virtualenv
  desc "Toolkit for developing mapping applications"
  homepage "https://mapnik.org/"
  url "https://github.com/mapnik/mapnik/releases/download/v3.0.22/mapnik-v3.0.22.tar.bz2"
  sha256 "930612ad9e604b6a29b9cea1bc1de85cf7cf2b2b8211f57ec8b6b94463128ab9"
  # url "https://github.com/mapnik/mapnik.git",
  #   :branch => "v3.0.x",
  #   :commit => "2ab8602f71809303ca180d495ecb89dfc27ba20d"
  # version "3.0.22"
  # https://github.com/mapnik/mapnik/wiki/MacInstallation_Homebrew

  revision 2

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "c05902125ce684e762a19af922d553b3aa100206977ab14464de61438dbfca7d" => :mojave
    sha256 "c05902125ce684e762a19af922d553b3aa100206977ab14464de61438dbfca7d" => :high_sierra
    sha256 "c05902125ce684e762a19af922d553b3aa100206977ab14464de61438dbfca7d" => :sierra
  end

  head "https://github.com/mapnik/mapnik.git", :branch => "master"

  option "with-pg10", "Build with PostgreSQL 10 client"

  depends_on "pkg-config" => :build
  depends_on "scons" => :build
  depends_on "boost"
  depends_on "boost-python"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "icu4c"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "osgeo-proj"
  depends_on "webp"
  depends_on "libjpeg-turbo"
  depends_on "libxml2"
  depends_on "python"
  # depends_on "python@2"

  depends_on "osgeo-postgis"
  depends_on "curl"
  depends_on "libtool"
  depends_on "libxslt"
  depends_on "httpd" #  => :optional
  depends_on "fcgi" # => :optional

  depends_on "cairo" # --without-x --without-glib
  depends_on "cairomm"
  depends_on "py2cairo"

  depends_on "sqlite"
  depends_on "zlib"
  depends_on "geos"
  depends_on "osgeo-gdal"

  depends_on "ossp-uuid"
  depends_on "libagg"
  depends_on "openjpeg" # for Pillow

  depends_on "git"
  depends_on "json-c"

  if build.with?("pg10")
    depends_on "osgeo-postgresql@10"
  else
    depends_on "osgeo-postgresql"
  end

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/81/1a/6b2971adc1bca55b9a53ed1efa372acff7e8b9913982a396f3fa046efaf8/Pillow-6.0.0.tar.gz"
    sha256 "809c0a2ce9032cbcd7b5313f71af4bdc5c8c771cb86eb7559afd954cab82ebb5"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/7d/29/174d70f303016c58bd790c6c86e6e86a9d18239fac314d55a9b7be501943/lxml-4.3.3.tar.gz"
    sha256 "4a03dd682f8e35a10234904e0b9508d705ff98cf962c5851ed052e9340df3d90"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  resource "geometry" do
    url "https://github.com/mapbox/geometry.hpp.git",
      :branch => "master",
      :commit => "c83a2ab18a225254f128b6f5115aa39d04f2de21"
    version "1.1.5"
  end

  resource "polylabel" do
    url "https://github.com/mapbox/polylabel.git",
      :branch => "master",
      :commit => "23f6a762ef2873519b86d46b625dd80f340e3dc3"
    version "1.1.5"
  end

  resource "protozero" do
    url "https://github.com/mapbox/protozero.git",
      :branch => "master",
      :commit => "3ef46ba780cad2caaf56a31fe35d102b069cdf0d"
    version "1.1.5"
  end

  resource "variant" do
    url "https://github.com/mapbox/variant.git",
      :branch => "master",
      :commit => "0f734f01e685a298e3756d30044a4164786c58c5"
    version "1.1.5"
  end

  # Use pkg-config to find FreeType2 if available
  # patch do
  #   url "https://github.com/mapnik/mapnik/pull/3892.patch"
  #   sha256 "774a8590b698e9dc2a483e6ff48781ed0400ba06b901f12a1ed50c9114833d47"
  # end

  def install
    ENV.cxx11

    # Work around "error: no member named 'signbit' in the global namespace"
    # encountered when trying to detect boost regex in configure
    ENV.delete("SDKROOT") if DevelopmentTools.clang_build_version >= 900

    # ENV.append "CPPPATH", "#{HOMEBREW_PREFIX}/include"
    # ENV.append "LIBPATH", "#{HOMEBREW_PREFIX}/lib"

    # install python modules
    venv = virtualenv_create(libexec/'vendor', "#{Formula["python"].opt_bin}/python3")
    res = resources.map(&:name).to_set - %w[geometry polylabel protozero variant]
    res.each do |r|
      venv.pip_install resource(r)
    end

    # fix error: use of undeclared identifier 'sqlite3_enable_load_extension'
    # https://github.com/mapnik/mapnik-support/issues/119
    # ENV.append "PATH", "#{Formula["sqlite"].opt_bin}:$PATH"
    ENV.append "CUSTOM_CXXFLAGS", "-I#{Formula["sqlite"].opt_include}"
    ENV.append "CUSTOM_LDFLAGS", "-L#{Formula["sqlite"].opt_lib} -lsqlite3"

    args = %W[
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      PREFIX=#{prefix}
      CPP_TESTS=FALSE
      INPUT_PLUGINS=all
      NIK2IMG=FALSE
    ]

    # support for PROJ 6
    # https://github.com/mapnik/mapnik/issues/4036
    # ENV.append_to_cflags "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"
    # args << "CUSTOM_DEFINES=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"

    # http://site.icu-project.org/download/61#TOC-Migration-Issues
    # ENV.append "CXXFLAGS", "-DU_USING_ICU_NAMESPACE=1"
    # https://github.com/mapnik/mapnik/issues/3961
    # ENV.append "CUSTOM_CXXFLAGS", "-DU_USING_ICU_NAMESPACE=1"

    # mapnik compiles can take ~1.5 GB per job for some .cpp files
    # so lets be cautious by limiting to CPUS/2
    # jobs = sysctl -n hw.ncpu
    jobs = ENV.make_jobs.to_i
    jobs /= 2 if jobs > 2

    args << "JOBS=#{jobs}"

    args << "CUSTOM_CXXFLAGS=#{ENV["CUSTOM_CXXFLAGS"]}"
    args << "CUSTOM_LDFLAGS=#{ENV["CUSTOM_LDFLAGS"]}"
    # args << "CUSTOM_CFLAGS=#{ENV["CUSTOM_CFLAGS"]}"

    # SYSTEM_FONTS=/usr/share/fonts

    # args << "PYTHON_PREFIX=#{prefix}"  # Install to Homebrew's site-packages // OLD

    args << "LINKING=shared"
    args << "RUNTIME_LINK=shared"
    args << "THREADING=multi"
    args << "INTERNAL_LIBAGG=False"
    args << "BENCHMARK=FALSE"
    # args << "DEMO=False"

    args << "BOOST_INCLUDES=#{Formula["boost"].opt_include}"
    args << "BOOST_LIBS=#{Formula["boost"].opt_lib}"
    args << "FREETYPE_CONFIG=#{Formula["freetype"].opt_bin}/freetype-config"
    args << "FREETYPE_INCLUDES=#{Formula["freetype"].opt_include}/freetype2"
    args << "FREETYPE_LIBS=#{Formula["freetype"].opt_lib}"

    # fails if defined
    # args << "ICU_INCLUDES=#{Formula["icu4c"].opt_include}/unicode"
    # args << "ICU_LIBS=#{Formula["icu4c"].opt_lib}"
    # args << "ICU_LIB_NAME=#{Formula["icu4c"].opt_lib}"

    args << "CAIRO=TRUE"
    args << "CAIRO_INCLUDES=#{Formula["cairo"].opt_include}"
    args << "CAIRO_LIBS=#{Formula["cairo"].opt_lib}"

    args << "PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/X11/lib/pkgconfig"

    args << "GRID_RENDERER=TRUE"

    # args << "SVG2PNG=True" # Error: Failed changing install name in /bin/svg2png
    args << "SVG_RENDERER=TRUE"

    args << "PNG=TRUE"
    args << "PNG_INCLUDES=#{Formula["libpng"].opt_include}"
    args << "PNG_LIBS=#{Formula["libpng"].opt_lib}"
    args << "JPEG=TRUE"
    args << "JPEG_INCLUDES=#{Formula["jpeg"].opt_include}"
    args << "JPEG_LIBS=#{Formula["jpeg"].opt_lib}"
    args << "TIFF=TRUE"
    args << "TIFF_INCLUDES=#{Formula["libtiff"].opt_include}"
    args << "TIFF_LIBS=#{Formula["libtiff"].opt_lib}"
    args << "WEBP=TRUE"
    args << "WEBP_INCLUDES=#{Formula["webp"].opt_include}"
    args << "WEBP_LIBS=#{Formula["webp"].opt_lib}"

    args << "GEOS_CONFIG=#{Formula["geos"].opt_bin}/geos-config"

    args << "GDAL_CONFIG=#{Formula["osgeo-gdal"].opt_bin}/gdal-config"
    args << "OCCI_INCLUDES=#{Formula["osgeo-gdal"].opt_include}"
    args << "OCCI_LIBS=#{Formula["osgeo-gdal"].opt_lib}"
    args << "RASTERLITE_INCLUDES=#{Formula["osgeo-gdal"].opt_include}"
    args << "RASTERLITE_LIBS=#{Formula["osgeo-gdal"].opt_lib}"

    args << "XML2_CONFIG=#{Formula["libxml2"].opt_bin}/xml2-config"
    args << "XML2_INCLUDES=#{Formula["libxml2"].opt_include}"
    args << "XML2_LIBS=#{Formula["libxml2"].opt_lib}"
    # fails if defined
    # args << "XMLPARSER=libxml2"
    # args << "OPTIONAL_LIBSHEADERS=#{Formula["libxml2"].opt_include}"

    args << "HB_INCLUDES=#{Formula["harfbuzz"].opt_include}"
    args << "HB_LIBS=#{Formula["harfbuzz"].opt_lib}"

    args << "PROJ=TRUE"
    args << "PROJ_INCLUDES=#{Formula["osgeo-proj"].opt_include}"
    args << "PROJ_LIBS=#{Formula["osgeo-proj"].opt_lib}"

    # fails if defined
    # args << "SQLITE_INCLUDES=#{Formula["sqlite"].opt_include}"
    # args << "SQLITE_LIBS=#{Formula["sqlite"].opt_lib}"

    if build.with?("pg10")
      args << "PG_CONFIG=#{Formula["osgeo-postgresql@10"].opt_bin}/pg_config"
      args << "PG_INCLUDES=#{Formula["osgeo-postgresql@10"].opt_include}"
      args << "PG_LIBS=#{Formula["osgeo-postgresql@10"].opt_lib}"
    else
      args << "PG_CONFIG=#{Formula["osgeo-postgresql"].opt_bin}/pg_config"
      args << "PG_INCLUDES=#{Formula["osgeo-postgresql"].opt_include}"
      args << "PG_LIBS=#{Formula["osgeo-postgresql"].opt_lib}"
    end

    args << "PGSQL2SQLITE=True"

    # link variant as submodules are missing from source tarball
    # https://github.com/mapnik/mapnik/issues/3246#issuecomment-279646631

    # this is faster than doing "git submodule update..."

    # rm_r "#{buildpath}/deps/mapbox/geometry"
    # rm_r "#{buildpath}/deps/mapbox/polylabel"
    # rm_r "#{buildpath}/deps/mapbox/protozero"
    rm_r "#{buildpath}/deps/mapbox/variant"

    # rm_r "#{buildpath}/demo"

    (buildpath/"deps/mapbox/geometry").install resource("geometry")
    (buildpath/"deps/mapbox/polylabel").install resource("polylabel")
    (buildpath/"deps/mapbox/protozero").install resource("protozero")
    (buildpath/"deps/mapbox/variant").install resource("variant")

    # git submodule update --init
    # system "git submodule update --init --recursive"

    # rm_r ".sconf_temp"

    system "./configure", *args
    # system "./configure", 'CUSTOM_CXXFLAGS="-DU_USING_ICU_NAMESPACE=1"', *args
    # ./configure CXX="clang++" JOBS=`sysctl -n hw.ncpu`
    # To use a Python interpreter that is not named python for your build,
    # do something like the following instead:
    # PYTHON=python2 ./configure
    # make PYTHON=python2
    system "make"
    system "make", "install"

    # system "#{Formula["python"].opt_bin}/python3", "scons/scons.py", "./configure", "--config=cache", "--implicit-cache", "--max-drift=1", *args # "--jobs=${jobs}
    # system "#{Formula["python"].opt_bin}/python3", "scons/scons.py"
    # system "#{Formula["python"].opt_bin}/python3", "scons/scons.py", "install"
  end

  # def post_install
      # Boost-Python Link Problems
      # After you install mapnik, you may try to import it and get Fatal Python
      # error: Interpreter not initialized (version mismatch?). If so, you likely
      # have boost linked with the wrong version of python.
      # otool -L `brew list boost | grep python-mt.dylib` | grep -i python
      # It's likely that your copy of boost was linked against the system python,
      # but you're trying to use a homebrew python. To fix, uninstall boost,
      # and reinstall with --build-from-source:
      # brew uninstall boost
      # brew install --build-from-source boost

      # Mapbox Variant not found problem
      # After git clone of mapnik, execute the following to pull down additional dependencies
      # system "git submodule update --init deps/mapbox/variant"
  # end

  # def caveats; <<-EOS
  #   For non-homebrew Python, you need to amend your PYTHONPATH like so:
  #     export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH
  #   EOS
  # end

  test do
    output = shell_output("#{bin}/mapnik-config --prefix").chomp
    assert_equal prefix.to_s, output
  end

  # private

  # def which_python
  #   "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  # end
end
