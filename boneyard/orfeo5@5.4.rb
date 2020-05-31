class Orfeo5AT54 < Formula
  desc "Library of image processing algorithms"
  homepage "http://www.orfeo-toolbox.org/otb/"
  url "https://github.com/orfeotoolbox/OTB/archive/5.4.0.tar.gz"
  sha256 "d232e8099bab7d9777ab2213a8fc1bf97d6731db88dad8963aa930f2ac13e38f"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "41187da6cafbc580f1eb05d75f3491581cc53903d87d2e24052abc07d708ec9e" => :sierra
  end

  keg_only "to avoid conflict with newer OTB installs"

  option "with-iceviewer", "Build with ICE Viewer application (Qt4 and X11 required)"
  option "with-examples", "Compile and install various examples"
  option "with-java", "Enable Java support"
  # option "with-patented", "Enable patented algorithms"

  depends_on "cmake" => :build

  # required
  depends_on "boost"
  depends_on "osgeo-vtk"
  depends_on "brewsci/science/insighttoolkit"
  depends_on "osgeo-libgeotiff"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "openssl"
  depends_on "ossim@2.1"
  depends_on "sqlite"
  depends_on "tinyxml"
  depends_on "open-scene-graph" # (for libOpenThreads, now internal to osg)
  depends_on "zlib"

  # recommended
  depends_on "muparser" => :recommended
  depends_on "libkml" => :recommended
  depends_on "libsvm" => :recommended
  depends_on "minizip" => :recommended

  # optional
  depends_on "python@2" => :optional
  depends_on "swig" if build.with? "python@2"
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "mapnik" => :optional
  depends_on "brewsci/science/opencv" => :optional
  depends_on "openjpeg" => :optional

  # ICE Viewer: needs X11 support
  if build.with? "iceviewer"
    depends_on "freeglut"
    depends_on "gdal2"
    depends_on "glew"
    depends_on "glfw"
    depends_on "qt-4"
  else
    depends_on "gdal2" => :recommended
    depends_on "glew" => :optional
    depends_on "glfw" => :optional
    depends_on "qt-4" => :optional
  end

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb-data/raw/master/Input/DEM/egm96.grd"
    sha256 "2babe341e8e04db11447e823ac0dfe4b17f37fd24c7966bb6aeab85a30d9a733"
    version "5.0.0"
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %w[
      -DOTB_BUILD_DEFAULT_MODULES=ON
      -DBUILD_TESTING=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_MACOSX_RPATH=OFF
    ]

    if build.with? "iceviewer"
      fg = Formula["freeglut"]
      args << "-DGLUT_INCLUDE_DIR=#{fg.opt_include}"
      args << "-DGLUT_glut_LIBRARY=#{fg.opt_lib}/libglut.dylib"
    end

    args << "-DBUILD_EXAMPLES=" + (build.with?("examples") ? "ON" : "OFF")
    # args << "-DOTB_USE_PATENTED=" + (build.with?("patented") ? "ON" : "OFF")
    args << "-DOTB_WRAP_JAVA=" + (build.with?("java") ? "ON" : "OFF")
    args << "-DOTB_WRAP_PYTHON=OFF" if build.without? "python@2"
    args << "-DITK_USE_FFTWF=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + (build.with?("fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")

    args << "-DOTB_USE_CURL=ON"
    args << "-DOTB_USE_GLEW=" + (build.with?("glew") || build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_GLFW=" + (build.with?("glfw") || build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_GLUT=" + (build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBKML=" + (build.with?("libkml") ? "ON" : "OFF")
    args << "-DOTB_USE_LIBSVM=" + (build.with?("libsvm") ? "ON" : "OFF")
    args << "-DOTB_USE_MAPNIK=" + (build.with?("mapnik") ? "ON" : "OFF")
    args << "-DOTB_USE_MUPARSER=" + (build.with?("muparser") ? "ON" : "OFF")
    # args << "-DOTB_USE_MUPARSERX=" + (build.with?("") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + (build.with?("opencv") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENGL=" + (build.with?("examples") || build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENJPEG=" + (build.with?("openjpeg") ? "ON" : "OFF")
    args << "-DOTB_USE_QT4=" + (build.with?("qt-4") || build.with?("iceviewer") ? "ON" : "OFF")
    args << "-DOTB_USE_SIFTFAST=ON"

    mkdir "build" do
      system "cmake", "..", *args
      # bbedit = "/usr/local/bin/bbedit"
      # cmake_config = Pathname("#{Dir.pwd}/orfeo5@5.4_cmake-config.txt")
      # cmake_config.write ["cmake ..", *args].join(" \\\n")
      # system bbedit, cmake_config.to_s
      # system bbedit, "CMakeCache.txt"
      # raise
      system "make"
      system "make", "install"
    end

    # clean up any unneeded otbgui script wrappers
    unless (bin/"otbgui").exist?
      rm_f Dir["#{bin}/otbgui*"]
    end

    # make env-wrapped command line utility launcher scripts
    envars = {
      :GDAL_DATA => "#{Formula["gdal2"].opt_share}/gdal",
      :OTB_APPLICATION_PATH => "#{opt_lib}/otb/applications",
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
