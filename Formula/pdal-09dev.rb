class Pdal09dev < Formula
  homepage "http://pointcloud.org"
  # TODO: remove. temp url in preparation for next release
  url "https://github.com/PDAL/PDAL.git",
      :revision => "42f66a06e9fcdca75572f44392f346ef4a8fb465"
  version "1.0.0b1-42f66a"

  head "https://github.com/PDAL/PDAL.git", :branch => "master"

  option "with-swig", "Build with Python bindings"
  option "with-icebridge", "Build with HDF5 IceBridge support"
  option "with-mrsid", "Build with proprietary MrSID format support"
  option "with-oracle", "Build with proprietary Oracle format support"
  option "with-tests", "Run unit tests after build, prior to install"
  option "with-doc", "Install API documentation and tutorial"

  depends_on "cmake" => :build
  depends_on "swig" => [:build, :optional]
  depends_on "boost"
  depends_on :python # for PLang filters
  depends_on "numpy" => :python
  depends_on "libgeotiff"
  depends_on "gdal"
  depends_on "postgresql" => :recommended
  depends_on "nitro" => :recommended
  depends_on "laszip" => :recommended
  depends_on "points2grid" => :recommended
  depends_on "hexer" => :recommended
  depends_on "sqlite" => :recommended
  depends_on "pcl" => :optional
  depends_on "hdf5" => :optional

  # proprietary formats
  depends_on "mrsid-sdk" if build.with? "mrsid"
  depends_on "oracle-client-sdk" if build.with? "oracle"

  conflicts_with "pdal", :because => "pdal 0.9.8 is in main tap"

  if build.with? "doc"
    depends_on "doxygen"
    depends_on "sphinx" => :python
    depends_on "breathe" => :python
  end

  # needs :cxx11

  def install
    ENV.libxml2
    args = std_cmake_args.concat %W[
    ]
    args << "-DWITH_TESTS=FALSE" if build.without? "tests"

    if brewed_python?
      args << "-DBUILD_PLUGIN_PYTHON=TRUE"
      args << "-DPYTHON_INCLUDE_DIR=#{brewed_python_framework}/Headers"
      args << "-DPYTHON_LIBRARY=#{brewed_python_framework}/Python"
    end
    args << "-DWITH_SWIG_PYTHON=TRUE" if build.with? "swig"
    if build.with? "icebridge"
        args << "-DBUILD_PLUGIN_ICEBRIDGE=ON" if build.with? "icebridge"
    end

    args << "-DBUILD_PLUGIN_PGPOINTCLOUD=FALSE" if build.without? "postgresql"
    args << "-DWITH_LASZIP=FALSE" if build.without? "laszip"
    args << "-DBUILD_PLUGIN_P2G=TRUE" if build.with? "points2grid"
    args << "-DWITH_GEOTIFF=ON" if build.with? "points2grid"
    args << "-DBUILD_PLUGIN_HEXBIN=ON" if build.with? "hexer"
    args << "-DBUILD_PLUGIN_SQLITE=ON" if build.with? "sqlite"
    args << "-DBUILD_PLUGIN_NITF=ON" if build.with? "nitro"
    args << "-DBUILD_PLUGIN_PCL=ON" if build.with? "pcl"
    args << "-DBUILD_PLUGIN_ICEBRIDGE=ON" if build.with? "hdf5"
#     args << "-DBUILD_PLUGIN_ATTRIBUTE=ON"
#     args << "-DWITH_GEOTIFF=ON"

    # proprietary formats
    if build.with? "mrsid"
      # TODO: remove cxxstdlib_check, after LizardTech updates binaries for libc++
      #       https://www.lizardtech.com/forums/viewtopic.php?f=6&t=821
      cxxstdlib_check :skip
      args << "-DBUILD_PLUGIN_MRSID=TRUE"
      args << "-DMRSID_ROOT=#{Formula["mrsid-sdk"].opt_prefix}"
    end
    if build.with? "oracle"
      # TODO: remove cxxstdlib_check, after Oracle updates binaries for libc++
      cxxstdlib_check :skip
      args << "-DBUILD_PLUGIN_OCI=TRUE"
      ENV["ORACLE_HOME"] = Formula["oracle-client-sdk"].opt_prefix
    else
      args << "-DBUILD_PLUGIN_OCI=FALSE"
    end

    mkdir "build" do
      ENV.libcxx if MacOS.version < :mavericks
      if ENV.compiler == :clang and MacOS.version < :mavericks
        # ENV.append "CFLAGS", "-stdlib=libc++"
        # ENV.append "LDFLAGS", "-stdlib=libc++"
      end
      system "cmake", "..", *args
      #system "bbedit", "CMakeCache.txt"
      #raise
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

    if build.with? "doc"
      cd "doc" do
        # nix need for `doxygen --with-dot` (and lengthy diagram generation)
        inreplace "doxygen/doxygen.conf" do |s|
          s.sub! /(HAVE_DOT\s*=\s*)YES/, "\\1NO"
        end
        inreplace "conf.py" do |s|
          s.sub! ",'rst2pdf.pdfbuilder'", "" # not needed for just html
          s.sub! '"indexsidebar.html",', "" # don't load ohloh sidebar
          s.sub! /^\s*'disqus_shortname':\s*'pdal',$/, "" # don't load discus
        end
        system "make", "doxygen"
        system "make", "html"
        doc.install "doxygen/html" => "api"
        doc.install "build/html" => "html"
      end
    end
  end

  private
  # python utils (deprecated in latest Homebrew)
  # see: https://github.com/Homebrew/homebrew/pull/24842

  def which_python
    "python" + %x(python -c "import sys;print(sys.version[:3])").strip
  end

  def brewed_python_framework
    HOMEBREW_PREFIX/"Frameworks/Python.framework"
  end

  def brewed_python?
    Formula["python"].linked_keg.exist? and brewed_python_framework.exist?
  end
end
