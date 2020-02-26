class OsgeoOrfeo < Formula
  desc "Library of image processing algorithms"
  homepage "https://www.orfeo-toolbox.org/otb"
  url "https://github.com/orfeotoolbox/OTB/archive/7.0.0.tar.gz"
  sha256 "cd81a538cda6420e06a921bb575f5c25e204f9c382aac23e161d91e583aaf22a"

  revision 2

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "b2d8e36b3f822fbfc8b7036bed3e6e0db9df8dbeb1630f287b1cce828b7fd7fc" => :catalina
    sha256 "b2d8e36b3f822fbfc8b7036bed3e6e0db9df8dbeb1630f287b1cce828b7fd7fc" => :mojave
    sha256 "b2d8e36b3f822fbfc8b7036bed3e6e0db9df8dbeb1630f287b1cce828b7fd7fc" => :high_sierra
  end

  head "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb.git", :branch => "master"

  # Errors found when using ITK 5
  # https://github.com/InsightSoftwareConsortium/ITKNeuralNetworks/issues/13
  # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/merge_requests/194
  ###################
  # CMake Error at /usr/local/opt/osgeo-insighttoolkit/lib/cmake/ITK-5.0/ITKModuleAPI.cmake
  #  No such module: "ITKNeuralNetworks"
  # Modules/ThirdParty/ITK/otb-module-init.cmake
  # CMake/OTBModuleEnablement.cmake
  # CMakeLists.txt
  ###################
  # /Modules/Core/Common/src/otbConfigurationManager.cxx: fatal error: 'itkMultiThreader.h' file not found
  # /Modules/Core/Metadata/src/otbImageMetadataInterfaceFactory.cxx: fatal error: 'itkMutexLock.h' file not found
  # Modules/Core/Metadata/src/otbImageMetadataInterfaceFactory.cxx: fatal error: 'ITKDeprecatedExport.h' file not found
  ###################
  # MPIConfig::Pointer MPIConfig::m_Singleton = NULL;
  # /usr/local/include/ITK-5.0/itkSmartPointer.h: note: candidate constructor
  #   constexpr SmartPointer (std::nullptr_t p) noexcept
  # /usr/local/include/ITK-5.0/itkSmartPointer.h: note: candidate constructor
  #   SmartPointer (ObjectType *p) noexcept

  # otbenv.profile
  patch :DATA

  option "without-monteverdi", "Build without Monteverdi and Mapla applications (Qt required)"
  option "without-python", "Build without Python support"
  option "with-patented", "Build with Patented Examples"
  option "with-examples", "Compile and install various examples"
  option "with-mpi", "Build with Open MPI, a High Performance Message Passing Library"
  # option "with-mapnik", "Build with Mapnik, toolkit for developing mapping applications"
  # option "with-shark", "Build with Machine learning library"
  # option "with-openjpeg", "Build with OpenJPEG, an open source JPEG 2000 codec"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "pkg-config"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "openssl"
  depends_on "sqlite"
  depends_on "tinyxml"
  depends_on "zlib"
  depends_on "expat"
  depends_on "gsl"
  depends_on "curl"
  depends_on "icu4c"
  depends_on "freetype"
  depends_on "perl"
  depends_on "libtool" # libltdl
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "geos"
  depends_on "openjpeg"
  depends_on "hdf5"
  depends_on "opencv@2"
  depends_on "python"
  depends_on "swig"
  depends_on "numpy"
  depends_on "fftw" # restricts built binaries to GPL license
  depends_on "libsvm" => :recommended
  depends_on "minizip" => :recommended
  depends_on "muparser" => :recommended
  depends_on "osgeo-libgeotiff"
  depends_on "osgeo-proj"
  depends_on "osgeo-hdf4"
  depends_on "osgeo-netcdf"
  depends_on "osgeo-muparserx" => :recommended
  depends_on "osgeo-libkml" => :recommended
  depends_on "osgeo-vtk"
  depends_on "osgeo-ossim"
  # depends_on "osgeo-insighttoolkit"
  depends_on "osgeo-insighttoolkit@4"
  depends_on "osgeo-openscenegraph" # (for libOpenThreads, now internal to osg)

  # ICE Viewer: needs X11 support
  # apparently, GLUT is not needed by Monteverdi, which uses ICE non-gui module,
  # but is needed for the ICE Viewer
  depends_on "freeglut"

  # Monteverdi: required deps and required/optionals shared with OTB
  depends_on "osgeo-gdal"
  depends_on "glew"
  depends_on "glfw"
  depends_on "qt"
  depends_on "qwt"

  # Need libagg if building mapnik
  # if build.with? "mapnik"
  #   depends_on "osgeo-mapnik"
  #   depends_on "libagg"
  # end

  # if build.with? "shark"
  #   depends_on "osgeo-shark"
  # end

  depends_on "open-mpi" if build.with? "mpi"

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
      -DOTB_USE_GSL=ON
    ]

    # fix error: no member named 'createRpcProjection' in 'ossimRpcSolver'
    # args << "-DOSSIM_VERSION=#{Formula["osgeo-ossim"].version}"
    args << "-DOSSIM_LIBRARY=#{Formula["osgeo-ossim"].opt_prefix}/Frameworks/ossim.framework"
    args << "-DOSSIM_INCLUDE_DIR=#{Formula["osgeo-ossim"].opt_include}"
    # args << "-DOSSIM_INCLUDE_DIR=#{Formula["osgeo-ossim"].opt_prefix}/Frameworks/ossim.framework/Headers"
    # find_path( OSSIM_INCLUDE_DIR NAMES ossim/init/ossimInit.h )

    # Simple Parallel Tiff Writer
    # args << "-DOTB_USE_SPTW=OFF"

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

    # -DCMAKE_CXX_FLAGS="$CXXFLAGS -fPIC"
    # -DCMAKE_C_FLAGS="$CFLAGS -fPIC"

    args << "-DOTB_DATA_USE_LARGEINPUT=ON"

    args << "-DOPENTHREADS_LIBRARY=#{Formula["osgeo-openscenegraph"].opt_lib}/libOpenThreads.dylib"
    args << "-DOPENTHREADS_INCLUDE_DIR=#{Formula["osgeo-openscenegraph"].opt_include}"

    args << "-DOTB_WRAP_JAVA=ON"

    # python
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python"
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

    args << "-DITK_DIR=#{Formula["cmake"].share}/cmake/Modules"

    # iceviewer
    fg = Formula["freeglut"]
    args << "-DGLUT_INCLUDE_DIR=#{fg.opt_include}"
    args << "-DGLUT_glut_LIBRARY=#{fg.opt_lib}/libglut.dylib"

    args << "-DOTB_USE_OPENCV=ON"
    args << "-Dopencv_INCLUDE_DIR=#{Formula['opencv@2'].include}"
    args << "-DOPENCV_core_LIBRARY=#{Formula['opencv@2'].lib}/libopencv_core.dylib"

    args << "-DBUILD_EXAMPLES=" + (build.with?("examples") ? "ON" : "OFF")

    args << "-DITK_USE_FFTWF=ON"
    args << "-DITK_USE_FFTWD=ON"
    args << "-DITK_USE_SYSTEM_FFTW=ON"
    args << "-DOTB_USE_CURL=ON"
    args << "-DOTB_USE_GLEW=ON"
    args << "-DOTB_USE_GLFW=ON"
    args << "-DOTB_USE_GLUT=ON"
    args << "-DOTB_USE_LIBKML=ON"
    args << "-DOTB_USE_LIBSVM=ON"
    args << "-DOTB_USE_MPI=ON"
    args << "-DOTB_USE_QT=ON"
    args << "-DOTB_USE_QWT=ON"
    args << "-DOTB_USE_SIFTFAST=ON"
    args << "-DOTB_USE_MUPARSER=ON"
    args << "-DOTB_USE_MUPARSERX=ON"

    # if build.with? "mapnik"
    #   args << "-DOTB_USE_MAPNIK=ON"
    #   args << "-DMAPNIK_LIBRARY=#{Formula["osgeo-mapnik"].opt_lib}/libmapnik.dylib"
    #   args << "-DMAPNIK_INCLUDE_DIR=#{Formula["osgeo-mapnik"].opt_include}/mapnik"
    #   args << "-DAGG_INCLUDE_DIR=#{Formula['libagg'].include}"
    # end

    # if build.with? "shark"
    #   args << "-DOTB_USE_SHARK=ON"
    # end

    args << "-DOTB_USE_OPENGL=ON"
    args << "-DOPENGL_INCLUDE_DIR=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"

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
      :GDAL_DATA => "#{Formula["osgeo-gdal"].opt_share}/gdal",
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
@@ -49,18 +49,18 @@
 PATH=$(cat_path "OUT_DIR/bin" "$PATH")

 # export PYTHONPATH to import otbApplication.py
-PYTHONPATH=$(cat_path "OUT_DIR/lib/python" "$PYTHONPATH")
+PYTHONPATH=OUT_DIR/lib/python3.7/site-packages:$PYTHONPATH

 # set numeric locale to C
 LC_NUMERIC=C

 # set GDAL_DATA variable used by otb application
-GDAL_DATA=OUT_DIR/share/gdal
+GDAL_DATA=HOMEBREW_PREFIX/opt/osgeo-gdal/share/gdal

 export GDAL_DRIVER_PATH=disable

 # set GEOTIFF_CSV variable used by otb application
-GEOTIFF_CSV=OUT_DIR/share/epsg_csv
+GEOTIFF_CSV=HOMEBREW_PREFIX/opt/osgeo-libgeotiff/share/epsg_csv

 # export variables
 export LC_NUMERIC

# --- a/CMakeLists.txt
# +++ b/CMakeLists.txt
# @@ -100,6 +100,12 @@
#  reset_qt_i18n_sources()
#
#  repository_status(${PROJECT_SOURCE_DIR} OTB_GIT_STATUS_MESSAGE)
# +
# +#if ITK_VERSION_MAJOR < 5
# +#define OTB_DISABLE_DYNAMIC_MT
# +#else
# +#define OTB_DISABLE_DYNAMIC_MT this->DynamicMultiThreadingOff();
# +#endif

 # Find python stuff
 # Version 3 is preferred before 2

# --- a/SuperBuild/CMake/External_itk.cmake
# +++ b/SuperBuild/CMake/External_itk.cmake
# @@ -84,7 +84,7 @@
#    Eigen
#    #FEM
#    NarrowBand
# -  NeuralNetworks
# +  #NeuralNetworks
#    Optimizers
#    Optimizersv4
#    Polynomials

# --- a/Modules/ThirdParty/ITK/otb-module-init.cmake
# +++ b/Modules/ThirdParty/ITK/otb-module-init.cmake
# @@ -71,7 +71,7 @@
#      ITKEigen
#      #ITKFEM
#      ITKNarrowBand
# -    ITKNeuralNetworks
# +    #ITKNeuralNetworks
#      ITKOptimizers
#      ITKOptimizersv4
#      ITKPolynomials
