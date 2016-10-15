class Orfeo5 < Formula
  desc "Library of image processing algorithms"
  homepage "http://www.orfeo-toolbox.org/otb/"
  url "https://github.com/orfeotoolbox/OTB/archive/5.4.0.tar.gz"
  sha256 "d232e8099bab7d9777ab2213a8fc1bf97d6731db88dad8963aa930f2ac13e38f"

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   cellar :any
  #   sha256 "" => :mavericks
  # end

  option "with-examples", "Compile and install various examples"
  option "with-java", "Enable Java support"
  # option "with-patented", "Enable patented algorithms"

  depends_on "cmake" => :build

  # required
  depends_on "boost"
  depends_on "homebrew/science/vtk"
  depends_on "homebrew/science/insighttoolkit"
  depends_on "libgeotiff"
  depends_on "ossim"
  depends_on "tinyxml"
  depends_on "open-scene-graph" # (for libOpenThreads, now internal to osg)

  # recommended
  depends_on "gdal2" => :recommended
  depends_on "qt-4" => :optional
  depends_on "muparser" => :recommended
  depends_on "libkml" => :recommended
  depends_on "libsvm" => :recommended
  depends_on "minizip" => :recommended

  # optional
  depends_on :python => :optional
  depends_on "mapnik" => :optional
  depends_on "openjpeg" => :optional
  depends_on "homebrew/x11/freeglut" => :optional
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "opencv" => :optional
  depends_on "glew" => :optional

  conflicts_with "orfeo", :because => "orfeo provides same functionality"

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "https://git.orfeo-toolbox.org/otb-data.git/blob_plain/88264d17dffd4269d36a4fb93a236a915f729515:/Input/DEM/egm96.grd"
    sha256 "2babe341e8e04db11447e823ac0dfe4b17f37fd24c7966bb6aeab85a30d9a733"
    version "5.0.0"
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DOTB_BUILD_DEFAULT_MODULES=ON
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_MACOSX_RPATH=OFF
    ]

    args << "-DBUILD_EXAMPLES=" + (build.with?("examples") ? "ON" : "OFF")
    # args << "-DOTB_USE_PATENTED=" + (build.with?("patented") ? "ON" : "OFF")
    args << "-DOTB_WRAP_JAVA=" + (build.with?("java") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python"
    args << "-DITK_USE_FFTWF=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")

    args << "-DOTB_USE_CURL=" + (build.with?("examples") ? "ON" : "OFF")
    args << "-DOTB_USE_GLEW=" + (build.with?("glew") ? "ON" : "OFF")
    # args << "-DOTB_USE_GLFW=" + (build.with?("") ? "ON" : "OFF")
    args << "-DOTB_USE_GLUT=" + (build.with?("freeglut") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBKML=" + (build.with?("libkml") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBSVM=" + (build.with?("libsvm") ? "ON" : "OFF")
    args << "-DOTB_USE_MAPNIK=" + (build.with?("mapnik") ? "ON" : "OFF")
    args << "-DOTB_USE_MUPARSER=" + (build.with?("muparser") ? "ON" : "OFF")
    # args << "-DOTB_USE_MUPARSERX=" + (build.with?("") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")
    # args << "-DOTB_USE_OPENGL=" + (build.with?("examples") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENJPEG=" + (build.with?("openjpeg") ? "ON" : "OFF")
    args << "-DOTB_USE_QT4=" + (build.with?("qt-4") ? "ON" : "OFF")
    # args << "-DOTB_USE_SIFTFAST=" + (build.with?("") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      # bbedit = "/usr/local/bin/bbedit"
      # cmake_config = Pathname("#{Dir.pwd}/orfeo5_cmake-config.txt")
      # cmake_config.write ["cmake ..", *args].join(" \\\n")
      # system bbedit, cmake_config.to_s
      # system bbedit, "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
    end
  end

  test do
    puts "Testing CLI wrapper"
    out = `#{opt_bin}/otbcli 2>&1`
    assert_match "module_name [MODULEPATH] [arguments]", out
    puts "Testing Rescale CLI app"
    out = `#{opt_bin}/otbcli_Rescale 2>&1`
    assert_match "Rescale the image between two given values", out
    if build.with? "qt-4"
      puts "Testing Qt GUI wrapper"
      out = `#{opt_bin}/otbgui 2>&1`
      assert_match "module_name [module_path]", out
    end
  end
end
