class OsgeoInsighttoolkitAT4 < Formula
  desc "ITK is a toolkit for performing registration and segmentation"
  homepage "https://www.itk.org"
  url "https://downloads.sourceforge.net/project/itk/itk/4.13/InsightToolkit-4.13.2.tar.gz"
  sha256 "d8760b279de20497c432e7cdf97ed349277da1ae435be1f6f0f00fbe8d4938c1"

  revision 3

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "1ddb7fb9794d353994d388e8e4e4408442fa2d3eef38dda01fadd6b42fb8d92a" => :catalina
    sha256 "1ddb7fb9794d353994d388e8e4e4408442fa2d3eef38dda01fadd6b42fb8d92a" => :mojave
    sha256 "1ddb7fb9794d353994d388e8e4e4408442fa2d3eef38dda01fadd6b42fb8d92a" => :high_sierra
  end

  head "https://github.com/InsightSoftwareConsortium/ITK.git", :branch => "master"

  # keg_only "Testing ITK - is not linked"

  option "with-examples", "Compile and install various examples"
  option "with-itkv3-compatibility", "Include ITKv3 compatibility"
  option "with-remove-legacy", "Disable legacy APIs"

  deprecated_option "examples" => "with-examples"
  deprecated_option "remove-legacy" => "with-remove-legacy"

  depends_on "cmake" => :build
  depends_on "opencv@2" => :recommended
  depends_on "python" => :recommended
  depends_on "fftw" => :recommended
  depends_on "hdf5" => :recommended
  # depends_on "jpeg" => :recommended
  depends_on "libjpeg-turbo" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "gdcm" => :optional
  depends_on "expat" unless OS.mac?

  depends_on "osgeo-vtk" => :build

  # JAVA_VERSION = "1.8" # "1.10+"
  depends_on :java => ["1.8", :build] # JAVA_VERSION

  depends_on "zlib"
  depends_on "bison"
  depends_on "libpng"
  depends_on "tcl-tk"
  depends_on "pcre"
  depends_on "swig"
  depends_on "castxml"
  depends_on "git"
  # depends_on "ruby"
  # depends_on "perl"

  def install
    ENV.cxx11

    # error: 'auto' not allowed in function return type
    # Modules/ThirdParty/VNL/src/vxl/core/vnl/vnl_math.h
    ENV.append "CXXFLAGS", "-std=c++11"

    # Temporary fix for Xcode/CLT 9.0.x issue of missing header files
    # See: https://github.com/OSGeo/homebrew-osgeo4mac/issues/276
    # Work around "error: no member named 'signbit' in the global namespace"
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    # Warning: python modules have explicit framework links
    # These python extension modules were linked directly to a Python
    # framework binary. They should be linked with -undefined dynamic_lookup
    # instead of -lpython or -framework Python
    # ENV["PYTHON_LIBS"] = "-undefined dynamic_lookup"
    # PYTHON_LDFLAGS=-undefined dynamic_lookup
    # PYTHON_EXTRA_LIBS=-undefined dynamic_lookup
    # PYTHON_EXTRA_LDFLAGS=-undefined dynamic_lookup

    # cmd = Language::Java.java_home_cmd("1.8") # JAVA_VERSION
    # ENV["JAVA_HOME"] = Utils.popen_read(cmd).chomp

    dylib = OS.mac? ? "dylib" : "so"

    args = std_cmake_args + %W[
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DITK_USE_64BITS_IDS=ON
      -DITK_USE_STRICT_CONCEPT_CHECKING=ON
      -DITK_USE_SYSTEM_ZLIB=ON
      -DITK_USE_SYSTEM_EXPAT=ON
      -DCMAKE_INSTALL_RPATH:STRING=#{lib}
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{lib}
      -DModule_SCIFIO=ON
    ]

    args << ".."
    args << "-DBUILD_EXAMPLES=" + (build.include?("examples") ? "ON" : "OFF")
    args << "-DModule_ITKVideoBridgeOpenCV=" + (build.with?("opencv") ? "ON" : "OFF")
    args << "-DITKV3_COMPATIBILITY:BOOL=" + (build.with?("itkv3-compatibility") ? "ON" : "OFF")

    args << "-DITK_USE_SYSTEM_FFTW=ON" << "-DITK_USE_FFTWF=ON" << "-DITK_USE_FFTWD=ON" if build.with? "fftw"
    args << "-DITK_USE_SYSTEM_HDF5=ON" if build.with? "hdf5"
    args << "-DITK_USE_SYSTEM_JPEG=ON" if build.with? "libjpeg-turbo" # jpeg
    args << "-DITK_USE_SYSTEM_PNG=ON" if build.with? :libpng
    args << "-DITK_USE_SYSTEM_TIFF=ON" if build.with? "libtiff"
    args << "-DITK_USE_SYSTEM_GDCM=ON" if build.with? "gdcm"
    args << "-DITK_LEGACY_REMOVE=ON" if build.include? "remove-legacy"
    args << "-DModule_ITKLevelSetsv4Visualization=ON"
    args << "-DModule_ITKReview=ON"
    args << "-DModule_ITKVtkGlue=ON"
    args << "-DITK_USE_GPU=" + (OS.mac? ? "ON" : "OFF")

    args << "-DVCL_INCLUDE_CXX_0X=ON" # for cxx11

    args << "-DITK_USE_SYSTEM_LIBRARIES=ON"
    args << "-DITK_USE_SYSTEM_SWIG=ON"
    args << "-DITK_USE_SYSTEM_CASTXML=ON"
    args << "-DITK_LEGACY_SILENT=ON"
    args << "-DModule_ITKIOMINC=ON"
    args << "-DModule_ITKIOTransformMINC=ON"
    # args << "-DITK_WRAP_TCL=ON"
    # args << "-DITK_WRAP_JAVA=ON"
    # args << "-DITK_WRAP_RUBY=ON"
    # args << "-DITK_WRAP_PERL=ON"

    # Could NOT find GTest
    # it is not installed
    args << "-DITK_USE_SYSTEM_GOOGLETEST=OFF"

    mkdir "itk-build" do
      python_executable = `which python3`.strip
      python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
      python_include = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
      python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp

      args << "-DITK_WRAP_PYTHON=ON"
      args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
      args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"

      # if PYTHON_EXECUTABLE
      # does not match Python's prefix
      # Python site-packages directory to install Python bindings
      # PY_SITE_PACKAGES_PATH

      # CMake picks up the system's python dylib, even if we have a brewed one.
      if File.exist? "#{python_prefix}/Python"
        args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
        args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.#{dylib}"
        args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.#{dylib}'"
      elsif File.exist? "#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.#{dylib}"
        args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/x86_64-linux-gnu/lib#{python_version}.#{dylib}'"
      else
        odie "No libpythonX.Y.{dylib|so|a} file found!"
      end

      system "cmake", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cxx").write <<-EOS
      #include "itkImage.h"

      int main(int argc, char* argv[])
      {
        typedef itk::Image< unsigned short, 3 > ImageType;
        ImageType::Pointer image = ImageType::New();
        image->Update();

        return EXIT_SUCCESS;
      }
    EOS

    dylib = OS.mac? ? "1.dylib" : "so.1"
    v=version.to_s.split(".")[0..1].join(".")
    # Build step
    system ENV.cxx, "-std=c++11", "-isystem", "#{include}/ITK-#{v}", "-o", "test.cxx.o", "-c", "test.cxx"
    # Linking step
    system ENV.cxx, "-std=c++11", "test.cxx.o", "-o", "test",
                    "#{lib}/libITKCommon-#{v}.#{dylib}",
                    "#{lib}/libITKVNLInstantiation-#{v}.#{dylib}",
                    "#{lib}/libitkvnl_algo-#{v}.#{dylib}",
                    "#{lib}/libitkvnl-#{v}.#{dylib}"
    system "./test"
  end
end
