require 'formula'

class Pdal < Formula
  homepage 'http://pointcloud.org'
  url 'https://github.com/PDAL/PDAL/archive/0.9.8.tar.gz'
  sha1 '6a6a76e6531473541746c19154630ff403099547'

  head 'https://github.com/PDAL/PDAL.git'

  option "with-caris", "Build with proprietary CARIS format support"
  option "with-mrsid", "Build with proprietary MrSID format support"
  option "with-oracle", "Build with proprietary Oracle format support"
  option "with-nitro", "Build with DoD LAS-inside-NITF containers support"
  option "with-swig", "Build with Python bindings"
  option "with-tests", "Run CTest after build, prior to install"

  depends_on 'cmake' => :build
  depends_on 'boost' # unit test errors when using pdal-internal boost
  depends_on :python => :recommended
  depends_on "swig" => :optional
  depends_on "proj" => :recommended
  depends_on "libgeotiff" => :recommended
  depends_on "gdal" => :recommended
  depends_on "laszip" => :recommended
  #depends_on "points2grid" => :optional # TODO: circular dependency fixable?
  depends_on "flann" => :recommended
  depends_on :postgresql => :recommended
  depends_on "hexer" => :recommended
  depends_on "nitro" => :optional

  # TODO: add [CARIS,] MrSID and Oracle, via HOMEBREW_LOCAL formulae

  # Fix swig rename error: "Cannot find source file: python/pdal.i"
  # Fix swig build error: headers for pdal not found
  # https://github.com/PDAL/PDAL/pull/239
  def patches
    if build.with? "swig"
      "https://gist.github.com/dakcarto/8721545/raw/15316b8a3933e07f03738b86e7108c1a4ad8e941/pdal-swig.diff"
    end
  end

  def install
    ENV.libxml2
    args = std_cmake_args
    # unit test errors when using pdal-internal boost
    args << "-DPDAL_EMBED_BOOST=FALSE"
    args << "-DWITH_ICONV=TRUE"
    args << "-DWITH_LIBXML2=TRUE"

    unless build.without? "python"
      args << "-DWITH_PYTHON=TRUE"
      if brewed_python?
        args << "-DPYTHON_INCLUDE_DIR=#{brewed_python_framework}/Headers"
        args << "-DPYTHON_LIBRARY=#{brewed_python_framework}/Python"
      end
    end
    if build.with? "swig"
      args << "-DWITH_SWIG_PYTHON=TRUE"
      # Fix rename error: "Cannot find source file: python/pdal.i"
      # https://github.com/PDAL/PDAL/pull/239
      mv "python/libpc.i", "python/pdal.i"
    end

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
      system "make"
      puts %x(ctest -VV .) if build.with? "tests"
      system "make", "install"
      if build.with? "swig"
        cd "python" do
          py_site = lib/which_python/"site-packages"
          py_site.mkpath
          py_site.install %W[_pdal.so pdal.py]
        end
      end
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

  def which_python
    "python" + %x(python -c 'import sys;print(sys.version[:3])').strip
  end

  def brewed_python_framework
    HOMEBREW_PREFIX/"Frameworks/Python.framework"
  end

  def brewed_python?
    Formula.factory("python").linked_keg.exist? and brewed_python_framework.exist?
  end
end
