require 'formula'

class Pdal < Formula
  homepage 'http://pointcloud.org'
  url 'https://github.com/PDAL/PDAL/archive/0.9.8.tar.gz'
  sha1 '6a6a76e6531473541746c19154630ff403099547'

  head 'https://github.com/PDAL/PDAL.git'

  option "with-caris", "Build with proprietary CARIS format support"
  option "with-mrsid", "Build with proprietary MrSID format support"
  option "with-oracle", "Build with proprietary Oracle format support"

  depends_on 'cmake' => :build
  depends_on 'boost' # TODO: is this necessary, since boost is internal?
  depends_on :python => :recommended
  depends_on "swig" => :optional # TODO: broken upstream?
  depends_on "proj" => :recommended
  depends_on "libgeotiff" => :recommended
  depends_on "gdal" => :recommended
  depends_on "laszip" => :recommended
  #depends_on "points2grid" => :optional # TODO: circular dependency fixable?
  depends_on "flann" => :recommended
  depends_on "postgres" => :recommended
  depends_on "hexer" => :recommended
  depends_on "nitro" => :recommended

  # TODO: add [CARIS,] MrSID and Oracle, via HOMEBREW_THIRD_PARTY formulae

  def install
    ENV.libxml2
    args = std_cmake_args
    args << "-DWITH_ICONV=TRUE"
    args << "-DWITH_LIBXML2=TRUE"

    unless build.without? "python"
      args << "-DWITH_PYTHON=TRUE"
      if brewed_python? and brewed_python_framework?
        args << "-DPYTHON_INCLUDE_DIR=#{brewed_python_framework}/Headers"
        args << "-DPYTHON_LIBRARY=#{brewed_python_framework}/Python"
      end
    end
    # TODO: python swig binding is broken upstream?:
    #       "Cannot find source file: python/pdal.i"
    args << "-DWITH_SWIG_PYTHON=TRUE" if build.with? "swig"

    args << "-DWITH_GEOTIFF=TRUE" unless build.without? "libgeotiff"
    args << "-DWITH_GDAL=TRUE" unless build.without? "gdal"
    args << "-DWITH_LASZIP=TRUE" unless build.without? "laszip"
    #args << "-DWITH_P2G=TRUE" # circular dependency
    args << "-DWITH_FLANN=TRUE" unless build.without? "flann"
    args << "-DWITH_PGPOINTCLOUD=TRUE" unless build.without? "postgres"
    args << "-DWITH_HEXER=TRUE" unless build.without? "hexer"
    args << "-DWITH_NITRO=TRUE" unless build.without? "nitro"

    # proprietary formats
    args << "-DWITH_CARIS=TRUE" if build.with? "caris"
    args << "-DWITH_MRSID=TRUE" if build.with? "mrsid"
    args << "-DWITH_ORACLE=TRUE" if build.with? "oracle"

    mkdir "build" do
      system "cmake", "..", *args
      #system 'bbedit', 'CMakeCache.txt'
      #raise
      system "make install"
    end
  end

  #def caveats; <<-EOS.undent
  #    To use 'drivers.p2g.writer' in PDAL to output point cloud interpolation,
  #    install the `points2grid` package, which depends on PDAL.
  #  EOS
  #end

  private
  # python utils (deprecated in latest Homebrew)
  # see: https://github.com/Homebrew/homebrew/pull/24842

  def brewed_python_framework
    HOMEBREW_PREFIX/"Frameworks/Python.framework"
  end

  def brewed_python_framework?
    brewed_python_framework.exist?
  end

  def brewed_python?
    Formula.factory("python").linked_keg.exist? and brewed_python_framework?
  end
end
