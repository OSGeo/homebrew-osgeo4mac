class OsgeoInsighttoolkit < Formula
  desc "ITK is a toolkit for performing registration and segmentation"
  homepage "https://www.itk.org"
  url "https://downloads.sourceforge.net/project/itk/itk/4.13/InsightToolkit-4.13.1.tar.gz"
  sha256 "fdcfd218bd6f99d1826c5fb18bb2d60ebc906e9589d70576c60360d7c6715147"

  revision 1

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "821a66bfa2f00ac11d6ee2b58215714593033cc06b452b2485ffa8820b1732e4" => :mojave
    sha256 "821a66bfa2f00ac11d6ee2b58215714593033cc06b452b2485ffa8820b1732e4" => :high_sierra
    sha256 "821a66bfa2f00ac11d6ee2b58215714593033cc06b452b2485ffa8820b1732e4" => :sierra
  end

  head "git://itk.org/ITK.git"

  option :cxx11
  option "with-examples", "Compile and install various examples"
  option "with-itkv3-compatibility", "Include ITKv3 compatibility"
  option "with-remove-legacy", "Disable legacy APIs"

  deprecated_option "examples" => "with-examples"
  deprecated_option "remove-legacy" => "with-remove-legacy"

  cxx11dep = build.cxx11? ? ["c++11"] : []

  depends_on "cmake" => :build
  depends_on "opencv@2" => [:recommended] + cxx11dep
  depends_on "python@2" if build.with? "python2"
  depends_on "python" => :recommended
  depends_on "fftw" => :recommended
  depends_on "hdf5" => [:recommended] + cxx11dep
  # depends_on "jpeg" => :recommended
  depends_on "libjpeg-turbo" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "gdcm" => [:optional] + cxx11dep
  depends_on "expat" unless OS.mac?

  if build.with? "python"
    depends_on "osgeo-vtk" => [:build, "with-python", "without-python2"] + cxx11dep
  elsif build.with? "python2"
    depends_on "osgeo-vtk" => [:build, "with-python2", "without-python"] + cxx11dep
  else
    depends_on "osgeo-vtk" => [:build] + cxx11dep
  end

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

    args << "-DVCL_INCLUDE_CXX_0X=ON" if build.cxx11?
    ENV.cxx11 if build.cxx11?

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

    mkdir "itk-build" do
      if build.with?("python") || build.with?("python2")
        python_executable = `which python2`.strip if build.with? "python2"
        python_executable = `which python3`.strip if build.with? "python"

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
    system ENV.cxx, "-isystem", "#{include}/ITK-#{v}", "-o", "test.cxx.o", "-c", "test.cxx"
    # Linking step
    system ENV.cxx, "test.cxx.o", "-o", "test",
                    "#{lib}/libITKCommon-#{v}.#{dylib}",
                    "#{lib}/libITKVNLInstantiation-#{v}.#{dylib}",
                    "#{lib}/libitkvnl_algo-#{v}.#{dylib}",
                    "#{lib}/libitkvnl-#{v}.#{dylib}"
    system "./test"
  end
end
