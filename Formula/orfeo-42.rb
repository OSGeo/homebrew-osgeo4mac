class Orfeo42 < Formula
  homepage "http://www.orfeo-toolbox.org/otb/"
  url "https://downloads.sourceforge.net/project/orfeo-toolbox/OTB-4.2.1.tgz"
  sha1 "c4f1299a2828a6f6acb81c1e022c706b7b7f10ea"

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha1 "55f60cff6d66ce5c82ded881def49f65a64e5d1e" => :mavericks
  end

  option "with-external-boost", "Build with brewed Boost"
  option "with-external-itk", "Build with brewed Insight Segmentation and Registration Toolkit"
  option "examples", "Compile and install various examples"
  option "java", "Enable Java support"
  option "patented", "Enable patented algorithms"

  depends_on "cmake" => :build
  depends_on "boost" if build.with? "external-boost"
  depends_on "homebrew/science/insighttoolkit" if build.with? "external-itk"
  depends_on :python => :optional
  depends_on "gdal"
  depends_on "qt"
  depends_on "muparser"
  depends_on "libkml"
  depends_on "minizip"
  depends_on "tinyxml"
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "opencv" => :optional
  # external libs that may work in next release:
  #depends on "open-scene-graph" # (for libOpenThreads, now internal to osg)

  conflicts_with "orfeo", :because => "orfeo provides same functionality"
  conflicts_with "orfeo-40", :because => "orfeo-40 provides same functionality"
  conflicts_with "orfeo-32", :because => "orfeo-32 provides same functionality"

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "http://hg.orfeo-toolbox.org/OTB-Data/raw-file/dec1ce83a5f3/Input/DEM/egm96.grd"
    sha1 "034ae375ff41b87d5e964f280fde0438c8fc8983"
    version "4.0.0"
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DBUILD_TESTING=OFF
      -DOTB_USE_EXTERNAL_OPENTHREADS=OFF
      -DBUILD_SHARED_LIBS=ON
      -DOTB_WRAP_QT=ON
      -DCMAKE_MACOSX_RPATH=OFF
    ]

    args << "-DOTB_USE_EXTERNAL_BOOST=" + (build.with?("external-boost") ? "ON" : "OFF")
    args << "-DOTB_USE_EXTERNAL_ITK=" + (build.with?("external-itk") ? "ON" : "OFF")
    args << "-DBUILD_EXAMPLES=" + (build.include?("examples") ? "ON" : "OFF")
    args << "-DOTB_WRAP_JAVA=" + (build.include?("java") ? "ON" : "OFF")
    args << "-DOTB_USE_PATENTED=" + (build.include?("patented") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python"
    args << "-DITK_USE_FFTWF=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")

    if build.without?("external-itk")
      # nix @rpath prefix for install names of libs for internal ITK build
      inreplace "Utilities/ITK/Modules/ThirdParty/KWSys/src/CMakeLists.txt",
                "set(KWSYS_PROPERTIES_CXX MACOSX_RPATH 1)", ""
      inreplace "Utilities/ITK/CMakeLists.txt" do |s|
        s.sub! "project(ITK)", "project(ITK)\nset(CMAKE_MACOSX_RPATH 0)"
        # Don't let internal ITK conflict with linking of insighttoolkit formula
        s.sub! "share/ITK-${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}", "\\0-orfeo"
        s.sub! "share/doc/ITK-${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}", "\\0-orfeo"
        s.sub! "lib/cmake/ITK-${ITK_VERSION_MAJOR}.${ITK_VERSION_MINOR}", "\\0-orfeo"
      end
    end

    mkdir "build" do
      system "cmake", "..", *args
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
    end
  end
end
