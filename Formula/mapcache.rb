class Mapcache < Formula
  desc "Server that implements tile caching to speed up access to WMS layers."
  homepage "http://mapserver.org/mapcache/"
  url "https://github.com/mapserver/mapcache/archive/rel-1-6-1.tar.gz"
  version "1.6.1"
  sha256 "1b3de277173100e89655b7c1361468c67727895a94152931e222a48b45a48caa"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any
    sha256 "48db39a4b97d78a01b20b5458fb7bed8e3eb2550f2d191ba6d08a30b1760662b" => :high_sierra
    sha256 "48db39a4b97d78a01b20b5458fb7bed8e3eb2550f2d191ba6d08a30b1760662b" => :sierra
  end

  option "with-tiff-cache", "Build with TIFFs as a cache backend"
  option "without-apache-module", "Build without Apache2 module"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "apr-util" => :build if build.with? "apache-module"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "pcre" => :recommended
  depends_on "pixman"
  depends_on "fcgi"
  depends_on "sqlite"
  depends_on "gdal"
  depends_on "geos"

  if build.with? "tiff-cache"
    depends_on "osgeo-libgeotiff"
    depends_on "libtiff"
  end
  depends_on "berkeley-db" => :optional
  depends_on "memcached" => :optional
  depends_on "mapserver" => :optional

  def lib_name
    "libmapcache"
  end

  def install
    args = std_cmake_args
    # option(WITH_SQLITE "Use sqlite as a cache backend" ON)
    # option(WITH_GEOS "Choose if GEOS geometry operations support should be built in" ON)
    # option(WITH_OGR "Choose if OGR/GDAL input vector support should be built in" ON)
    # option(WITH_CGI "Choose if CGI executable should be built" ON)
    # option(WITH_FCGI "Choose if CGI executable should support FastCGI" ON)
    # Fix up .fcgi install path
    args << "-DCMAKE_INSTALL_CGIBINDIR=#{libexec}"

    # option(WITH_VERSION_STRING "Show MapCache in server version string" ON)
    # option(WITH_APACHE "Build Apache Module" ON)
    if build.with? "apache-module"
      args << "-DCMAKE_PREFIX_PATH=#{Formula["apr"].opt_libexec}:#{Formula["apr-util"].opt_libexec}"
      args << "-DAPACHE_MODULE_DIR=#{libexec}"
    else
      args << "-DWITH_APACHE=OFF"
    end
    # option(WITH_PIXMAN "Use pixman for SSE optimized image manipulations" ON)
    # args << "-DWWITH_PIXMAN=" + (build.with?("pixman") ? "ON" : "OFF")
    # option(WITH_BERKELEY_DB "Use Berkeley DB as a cache backend" OFF)
    args << "-DWITH_BERKELEY_DB=" + (build.with?("berkeley-db") ? "ON" : "OFF")
    # option(WITH_MEMCACHE "Use memcache as a cache backend (requires recent apr-util)" OFF)
    args << "-DWITH_MEMCACHE=" + (build.with?("memcached") ? "ON" : "OFF")
    # option(WITH_PCRE "Use PCRE for regex tests" OFF)
    args << "-DWITH_PCRE=" + (build.with?("pcre") ? "ON" : "OFF")
    # option(WITH_MAPSERVER "Enable (experimental) support for the mapserver library" OFF)
    args << "-DWITH_MAPSERVER=" + (build.with?("mapserver") ? "ON" : "OFF")

    # option(WITH_TIFF "Use TIFFs as a cache backend" OFF)
    # option(WITH_TIFF_WRITE_SUPPORT "Enable (experimental) support for writable TIFF cache backends" OFF)
    # option(WITH_GEOTIFF "Allow GeoTIFF metadata creation for TIFF cache backends" OFF)
    args << "-DWITH_TIFF=" + (build.with?("tiff-cache") ? "ON" : "OFF")
    args << "-DWITH_GEOTIFF=" + (build.with?("tiff-cache") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
    end

    # update Apache module linking
    so_ver = 1
    lib_name_ver = "#{lib_name}.#{so_ver}"
    MachO::Tools.change_install_name("#{libexec}/mod_mapcache.so",
                                     "@rpath/#{lib_name_ver}.dylib",
                                     "#{opt_lib}/#{lib_name_ver}.dylib")

    # Add config examples
    (prefix/"config").mkpath
    cp Dir["mapcache.xml*"], prefix/"config"
  end

  def caveats; <<~EOS
    The MapCache FCGI executable and Apache module are located in:
      #{libexec}/

    Configuration examples are located in:
      #{prefix}/

  EOS
  end

  test do
    out = `#{opt_bin}/mapcache_seed -h`
    assert_match "tileset to seed", out
  end
end
