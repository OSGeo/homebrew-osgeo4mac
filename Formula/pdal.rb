require "formula"

class Pdal < Formula
  homepage "http://pointcloud.org"
  # TODO: remove. temp url in preparation for next release
  url "https://github.com/PDAL/PDAL.git",
      :revision => "caa9399ffa2ff50a8543f62bd678c2ff46786b83"
  version "0.9.9-caa9399"
  sha1 "caa9399ffa2ff50a8543f62bd678c2ff46786b83"

  head "https://github.com/PDAL/PDAL.git", :branch => "master"

  option "with-swig", "Build with Python bindings"
  option "with-soci", "Build with SOCI database access support"
  option "with-mrsid", "Build with proprietary MrSID format support"
  option "with-oracle", "Build with proprietary Oracle format support"
  option "with-tests", "Run unit tests after build, prior to install"
  option "with-doc", "Install API documentation and tutorial"

  depends_on "cmake" => :build
  depends_on "swig" => [:build, :optional]
  depends_on "boost" # has internal boost, but external recommended by developer
  depends_on :python # for PLang filters
  depends_on "numpy" => :python
  depends_on "libgeotiff"
  depends_on "gdal"
  depends_on :postgresql => :recommended
  depends_on "laszip" => :recommended
  depends_on "msgpack" => :recommended
  # TODO: nix tap dup once version points2grid 1.2.1 is pushed to main tap
  #       why doesn't :recommended work for taps?
  depends_on "dakcarto/osgeo4mac/points2grid" # => :recommended
  depends_on "hexer" => :recommended
  depends_on "soci" => :optional

  # proprietary formats
  depends_on "mrsid-sdk" if build.with? "mrsid"
  # TODO: add Oracle, via HOMEBREW_CACHE/archive formulae

  if build.with? "doc"
    depends_on "doxygen"
    depends_on "sphinx" => :python
    depends_on "breathe" => :python
  end

  def install
    ENV.libxml2
    args = std_cmake_args.concat %W[
      -DPDAL_EMBED_BOOST=FALSE
      -DWITH_NITRO=FALSE
    ]
    args << "-DWITH_TESTS=FALSE" if build.without? "tests"

    if brewed_python?
      args << "-DPYTHON_INCLUDE_DIR=#{brewed_python_framework}/Headers"
      args << "-DPYTHON_LIBRARY=#{brewed_python_framework}/Python"
    end
    args << "-DWITH_SWIG_PYTHON=TRUE" if build.with? "swig"

    args << "-DWITH_PGPOINTCLOUD=FALSE" if build.without? "postgresql"
    args << "-DWITH_LASZIP=FALSE" if build.without? "laszip"
    args << "-DWITH_MSGPACK=FALSE" if build.without? "msgpack"
    # TODO: re-add conditional once points2grid 1.2.1 is pushed to main tap
    args << "-DWITH_P2G=TRUE" # if build.with? "points2grid"
    args << "-DWITH_HEXER=TRUE" if build.with? "hexer"
    args << "-DWITH_SQLITE=TRUE" if build.with? "soci"

    # proprietary formats
    if build.with? "mrsid"
      # TODO: remove cxxstdlib_check, after LizardTech updates binaries for libc++
      #       https://www.lizardtech.com/forums/viewtopic.php?f=6&t=821
      cxxstdlib_check :skip
      args << "-DWITH_MRSID=TRUE"
      args << "-DMRSID_ROOT=#{Formula.factory("mrsid-sdk").opt_prefix}"
    end
    args << "-DWITH_ORACLE=FALSE" if build.without? "oracle"

    mkdir "build" do
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
    Formula.factory("python").linked_keg.exist? and brewed_python_framework.exist?
  end
end
