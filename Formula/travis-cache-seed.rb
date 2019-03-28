class TravisCacheSeed < Formula
  desc "Trigger update of Travis CI cache with geospatial dependencies"
  homepage "https://github.com/OSGeo/homebrew-osgeo4mac"
  url "https://osgeo4mac.s3.amazonaws.com/src/dummy.tar.gz"
  version "0.0.1"
  sha256 "e7776e2ff278d6460300bd69a26d7383e6c5e2fbeb17ff12998255e7fc4c9511"

  keg_only "because it doesn't really install anything"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison"
  depends_on "boost"
  depends_on "cairo"
  depends_on "cgal"
  depends_on "cmake" => :build
  depends_on "coreutils"
  depends_on "expat"
  depends_on "fcgi"
  depends_on "fftw"
  depends_on "flex"
  depends_on "freetype"
  depends_on "gdal2-python"
  depends_on "gdal2"
  depends_on "geos"
  depends_on "gettext"
  depends_on "ghostscript"
  # depends on "git"
  depends_on "glew"
  depends_on "glfw"
  # depends on "gnupg"
  # depends on "gpg-agent"
  depends_on "gpsbabel-qt4"
  depends_on "gsl"
  # depends on "brewsci/science/insighttoolkit"
  # depends on "brewsci/science/osgearth"
  depends_on "jpeg"
  depends_on "lbzip2"
  # depends on "libevent"
  depends_on "osgeo-libgeotiff"
  depends_on "libgpg-error"
  depends_on "libharu"
  depends_on "libkml"
  depends_on "libpng"
  depends_on "libssh"
  depends_on "libsvm"
  depends_on "libtiff"
  depends_on "libtool" => :build
  depends_on "minizip"
  depends_on "muparser"
  # depends on "mysql"
  # depends on "numpy"
  depends_on "open-scene-graph"
  depends_on "openssl"
  depends_on "osgeo-ossim"
  depends_on "pcre"
  depends_on "pkg-config" => :build
  # depends on "postgis" # creates dep on gdal 1.x
  depends_on "osgeo-postgresql"
  depends_on "osgeo-proj"
  depends_on "pyenv"
  depends_on "pyqt-qt4"
  depends_on "pyspatialite"
  depends_on "python"
  # depends on "python3"
  depends_on "qca-qt4"
  depends_on "qhull"
  depends_on "qjson-qt4"
  depends_on "qscintilla2-qt4"
  depends_on "qt-4"
  depends_on "qwt-qt4"
  depends_on "qwtpolar-qt4"
  depends_on "readline"
  depends_on "sfcgal"
  depends_on "sip-qt4"
  depends_on "spatialindex"
  depends_on "sqlite"
  depends_on "swig" => :build
  depends_on "tinyxml"
  depends_on "unixodbc"
  # depends on "vtk"
  # depends on "wxmac"
  # depends on "wxpython"
  depends_on "zlib"

  def install
    (share/"blank").write "blank"
  end

  def caveats; <<~EOS
    Formula does not install anything per se. Just updates cache at Travis CI
    with geospatial dependencies to reduce build times of larger formulae.

    Example `.travis.yml` settings:

      cache:
        directories:
          - /usr/local
        timeout: 900
      before_cache:
        - brew cleanup

    EOS
  end

  test do
    #
  end
end
