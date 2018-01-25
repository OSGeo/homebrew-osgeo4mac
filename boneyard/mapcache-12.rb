class Mapcache12 < Formula
  MAPSERVER = "mapserver-64"

  homepage "http://mapserver.org/mapcache/"
  url "https://github.com/mapserver/mapcache/archive/rel-1-2-1.tar.gz"
  sha256 "31c6c074324f609eda69743b288926c36bb23826eb6bf090f1146aaf31b59c20"
  version "1.2.1"

  option "with-tiff-cache", "Build with TIFFs as a cache backend"
  option "without-apache-module", "Build without Apache2 module"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "apr" => :build if build.with? "apache-module"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "pcre" => :recommended
  depends_on "pixman" => :recommended
  depends_on "fcgi"
  depends_on "sqlite"
  depends_on "gdal"
  depends_on "geos"

  if build.with? "tiff-cache"
    depends_on "libgeotiff"
    depends_on "libtiff"
  end
  depends_on "berkeley-db" => :optional
  depends_on "memcached" => :optional
  depends_on MAPSERVER => :optional

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
      args << "-DAPACHE_MODULE_DIR=#{libexec}"
    else
      args << "-DWITH_APACHE=OFF"
    end
    # option(WITH_PIXMAN "Use pixman for SSE optimized image manipulations" ON)
    args << "-DWWITH_PIXMAN=" + (build.with?("pixman") ? "ON" : "OFF")
    # option(WITH_BERKELEY_DB "Use Berkeley DB as a cache backend" OFF)
    args << "-DWITH_BERKELEY_DB=" + (build.with?("berkeley-db") ? "ON" : "OFF")
    # option(WITH_MEMCACHE "Use memcache as a cache backend (requires recent apr-util)" OFF)
    args << "-DWITH_MEMCACHE=" + (build.with?("memcached") ? "ON" : "OFF")
    # option(WITH_PCRE "Use PCRE for regex tests" OFF)
    args << "-DWITH_PCRE=" + (build.with?("pcre") ? "ON" : "OFF")
    # option(WITH_MAPSERVER "Enable (experimental) support for the mapserver library" OFF)
    args << "-DWITH_MAPSERVER=" + (build.with?(MAPSERVER) ? "ON" : "OFF")

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
end
