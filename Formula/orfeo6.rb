class Orfeo6 < Formula
  desc "Library of image processing algorithms"
  homepage "https://www.orfeo-toolbox.org/otb/"

  revision 3

  head "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb.git", :branch => "master"

  stable do
    url "https://github.com/orfeotoolbox/OTB/archive/6.6.1.tar.gz"
    sha256 "f8fea75f620fae1bb0ce902fb8133457b6ead40ad14d4dec55beaa59ae641b4c"

    # otbenv.profile
    patch :DATA
  end

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "f942a56c1b43b0f4ec33c6f24ada705cc560fb8e47a030f3a950ca849bf8a299" => :mojave
    sha256 "f942a56c1b43b0f4ec33c6f24ada705cc560fb8e47a030f3a950ca849bf8a299" => :high_sierra
    sha256 "f942a56c1b43b0f4ec33c6f24ada705cc560fb8e47a030f3a950ca849bf8a299" => :sierra
  end

  option "without-monteverdi", "Build without Monteverdi and Mapla applications (Qt required)"
  option "without-python", "Build without Python support"
  option "with-monteverdi", "Build with Monteverdi and Mapla applications (Qt required)"
  option "with-python", "Build with Python support"
  option "with-patented", "Build with Patented Examples"
  option "with-fftw", "Build with FFTW support"
  option "with-hdf5", "Build with HDF5, general purpose library and file format for storing scientific data support"
  option "with-iceviewer", "Build with ICE Viewer application (Qt and X11 required)"
  option "with-examples", "Compile and install various examples"
  option "with-java", "Enable Java support"
  option "with-mpi", "Build with Open MPI, a High Performance Message Passing Library"
  option "with-opencv", "Build with OpenCV support"
  # option "with-shark", "Build with Machine learning library"
  # option "with-mapnik", "Build with Mapnik, toolkit for developing mapping applications"
  # option "with-openjpeg", "Build with OpenJPEG, an open source JPEG 2000 codec"

  depends_on "cmake" => :build

  # required
  depends_on "boost"
  depends_on "osgeo-vtk"
  depends_on "osgeo-libgeotiff"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "openssl"
  depends_on "sqlite"
  depends_on "tinyxml"
  depends_on "zlib"
  depends_on "expat"
  depends_on "gsl"
  depends_on "curl"
  depends_on "pkg-config"
  depends_on "icu4c"
  depends_on "freetype"
  depends_on "perl"
  depends_on "libtool" # libltdl
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "osgeo-proj"
  depends_on "geos"
  depends_on "osgeo-netcdf"
  depends_on "openjpeg"
  depends_on "osgeo-ossim"
  depends_on "insighttoolkit"
  depends_on "openscenegraph-qt5" # (for libOpenThreads, now internal to osg)

  # recommended
  depends_on "muparser" => :recommended
  # depends_on "muparserx" => :recommended
  depends_on "libkml" => :recommended
  depends_on "libsvm" => :recommended
  depends_on "minizip" => :recommended

  # optional
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "hdf5" => :optional
  # depends_on "osgeo-hdf4" => :optional
  # depends_on "mapnik" => :optional
  # depends_on "shark" if build.with? "shark"
  depends_on "open-mpi" if build.with? "mpi"
  depends_on "opencv@2" if build.with? "opencv"
  if build.with? "python"
    depends_on "python" => :optional
    depends_on "swig"
    depends_on "numpy"
  end

  # ICE Viewer: needs X11 support
  # apparently, GLUT is not needed by Monteverdi, which uses ICE non-gui module,
  # but is needed for the ICE Viewer
  depends_on "freeglut" if build.with? "iceviewer"

  # Monteverdi: required deps and required/optionals shared with OTB
  if build.with? "monteverdi"
    depends_on "gdal2"
    depends_on "glew"
    depends_on "glfw"
    depends_on "qt"
    depends_on "qwt"
  else
    depends_on "gdal2" => :recommended
    depends_on "glew" => :optional
    depends_on "glfw" => :optional
    depends_on "qt" => :optional
  end

  # Need libagg if building mapnik
  if build.with? "mapnik"
    depends_on "libagg"
  end

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb-data/raw/master/Input/DEM/egm96.grd"
    sha256 "2babe341e8e04db11447e823ac0dfe4b17f37fd24c7966bb6aeab85a30d9a733"
    version "5.0.0"
  end

  # resource "GKSVM" do
  #   url "https://github.com/jmichel-otb/GKSVM.git",
  #     :branch => "master",
  #     :commit => "553dc8e40ab1538c46de6596ec323627dac5fea5"
  #   version "0.0.1"
  # end

  def install
    ENV.cxx11

    # Module for monteverdi build
    # if build.with? "monteverdi"
    #   (buildpath/"Modules/Remote").install resource("GKSVM")
    # end

    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DOTB_BUILD_DEFAULT_MODULES=ON
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_MACOSX_RPATH=OFF
      -DCMAKE_CXX_STANDARD=11
      -DQWT_LIBRARY=#{Formula["qwt"].lib}/qwt.framework
      -DQWT_INCLUDE_DIR=#{Formula["qwt"].lib}/qwt.framework/Headers
      -DOSSIM_LIBRARY=#{Formula["ossim"].opt_prefix}/Frameworks/ossim.framework
      -DOSSIM_INCLUDE_DIR=#{Formula["ossim"].include}
      -DOTB_USE_GSL=ON
    ]

    # Simple Parallel Tiff Writer
    # args << "OTB_USE_SPTW=OFF"

    # Option to activate deprecated classes
    # Turn on the use and test of deprecated classes
    # args << "-DOTB_USE_DEPRECATED=OFF"

    # Add openmp compiler and linker flags
    # args << "-DOTB_USE_OPENMP=OFF"

    # Enable SIMD optimizations (hardware dependent)
    # args << "-DOTB_USE_SSE_FLAGS=ON"

    # Enable module 6S
    # args << "-DOTB_USE_6S=ON"

    # Enable module Curl
    # args << "-DOTB_USE_CURL=ON"

    # Build with static libraries
    # args << "-DBUILD_STATIC_LIBS=OFF"

    # Build with specific list of remote modules
    # args << "-DWITH_REMOTE_MODULES=OFF"


    args << "-DOTB_DATA_USE_LARGEINPUT=ON"

    args << "-DOPENTHREADS_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libOpenThreads.dylib"
    args << "-DOPENTHREADS_INCLUDE_DIR=#{Formula["openscenegraph-qt5"].opt_include}"

    args << "-DOTB_WRAP_JAVA=" + (build.with?("java") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python"

    if build.with? "python"
      args << "-DOTB_WRAP_PYTHON=ON"
      args << "-DPYTHON_EXECUTABLE=#{HOMEBREW_PREFIX}/opt/python/bin/python3"
      py_ver= `#{HOMEBREW_PREFIX}/opt/python/bin/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
      args << "-DPYTHON_LIBRARY=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{py_ver}/lib/libpython#{py_ver}m.dylib"
      args << "-DPYTHON_LIBRARY_RELEASE=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{py_ver}/lib/libpython#{py_ver}m.dylib"
      # args << "-DPYTHON3_LIBRARY_DEBUG="
      args << "-DPYTHON_INCLUDE_DIR=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{py_ver}/include/python#{py_ver}m"
      # args << "-DNUMPY_PYTHON3_INCLUDE_DIR="
      args << "-DOTB_INSTALL_PYTHON_DIR=#{lib}/python#{py_ver}/site-packages/otb"

      args << "-DNUMPY_INCLUDE_DIR=#{Formula["numpy"].opt_lib}/python#{py_ver}/site-packages/numpy/core/include" # numpy/arrayobject.h
    end

    args << "-DITK_DIR=#{Formula["cmake"].share}/cmake/Modules"
    if build.with? "mapnik"
      args << "-DMAPNIK_INCLUDE_DIRS=#{Formula['mapnik'].include}/mapnik"
      args << "-DMAPNIK_LIBRARIES=#{Formula['mapnik'].lib}"
      args << "-DAGG_INCLUDE_DIR=#{Formula['libagg'].include}"
    end

    if build.with? "iceviewer"
      fg = Formula["freeglut"]
      args << "-DGLUT_INCLUDE_DIR=#{fg.opt_include}"
      args << "-DGLUT_glut_LIBRARY=#{fg.opt_lib}/libglut.dylib"
    end

    if build.with? "opencv"
      args << "-DOTB_USE_OPENCV=ON"
      args << "-Dopencv_INCLUDE_DIR=#{Formula['opencv@2'].include}"
      args << "-DOPENCV_core_LIBRARY=#{Formula['opencv@2'].lib}/libopencv_core.dylib"
    end

    args << "-DBUILD_EXAMPLES=" + (build.with?("examples") ? "ON" : "OFF")

    args << "-DITK_USE_FFTWF=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_CURL=ON"
    args << "-DOTB_USE_GLEW=" + ((build.with?("glew") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_GLFW=" + ((build.with?("glfw") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_GLUT=" + (build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBKML=" + (build.with?("libkml") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBSVM=" + (build.with?("libsvm") ? "ON" : "OFF")
    args << "-DOTB_USE_MAPNIK=" + (build.with?("mapnik") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENGL=" + ((build.with?("examples") || build.with?("iceviewer") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_MPI=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DOTB_USE_QT=" + ((build.with?("qt") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_QWT=" + ((build.with?("qt") || build.with?("monteverdi")) ? "ON" : "OFF")
    args << "-DOTB_USE_SIFTFAST=ON"
    args << "-DOTB_USE_MUPARSER=" + (build.with?("muparser") ? "ON" : "OFF")
    # args << "-DOTB_USE_MUPARSERX=" + (build.with?("muparserx") ? "ON" : "OFF")
    # args << "-DOTB_USE_SHARK=" + (build.with?("shark") ? "ON" : "OFF")

    # args << "-DOTB_USE_PATENTED=" + (build.with?("patented") ? "ON" : "OFF") # not used by the project
    # args << "-DOTB_USE_OPENJPEG=" + (build.with?("openjpeg") ? "ON" : "OFF") # not used by the project

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # A script to initialize the environment for OTB executables
    cp_r "#{buildpath}/Packaging/Files/otbenv.profile", "#{prefix}"

    # clean up any unneeded otbgui script wrappers
    rm_f Dir["#{bin}/otbgui*"] unless (bin/"otbgui").exist?

    # make env-wrapped command line utility launcher scripts
    envars = {
      :GDAL_DATA => "#{Formula["gdal2"].opt_share}/gdal",
      :OTB_APPLICATION_PATH => "#{opt_lib}/otb/applications",
      :OTB_FOLDER => "#{opt_prefix}",
      :OTB_GEOID_FILE => "#{opt_libexec}/default_geoid/egm96.grd",
    }
    bin.env_script_all_files(libexec/"bin", envars)
  end

  def caveats; <<~EOS
      The default geoid to use in elevation calculations is available in:

        #{opt_libexec}/default_geoid/egm96.grd
  EOS
  end

  test do
    puts "Testing CLI wrapper"
    out = `#{opt_bin}/otbcli 2>&1`
    assert_match "module_name [MODULEPATH] [arguments]", out
    puts "Testing Rescale CLI app"
    out = `#{opt_bin}/otbcli_Rescale 2>&1`
    assert_match "Rescale the image between two given values", out
    if (opt_bin/"otbgui").exist?
      puts "Testing Qt GUI wrapper"
      out = `#{opt_bin}/otbgui 2>&1`
      assert_match "module_name [module_path]", out
    end
  end
end

__END__

--- a/Packaging/Files/otbenv.profile
+++ b/Packaging/Files/otbenv.profile
@@ -37,18 +37,18 @@
 PATH=OUT_DIR/bin:$PATH

 # export PYTHONPATH to import otbApplication.py
-PYTHONPATH=OUT_DIR/lib/python:$PYTHONPATH
+PYTHONPATH=OUT_DIR/lib/python3.7/site-packages:$PYTHONPATH

 # set numeric locale to C
 LC_NUMERIC=C

 # set GDAL_DATA variable used by otb application
-GDAL_DATA=OUT_DIR/share/gdal
+GDAL_DATA=HOMEBREW_PREFIX/opt/gdal2/share/gdal

 export GDAL_DRIVER_PATH=disable

 # set GEOTIFF_CSV variable used by otb application
-GEOTIFF_CSV=OUT_DIR/share/epsg_csv
+GEOTIFF_CSV=HOMEBREW_PREFIX/opt/libgeotiff/share/epsg_csv

 # export variables
 export LC_NUMERIC
