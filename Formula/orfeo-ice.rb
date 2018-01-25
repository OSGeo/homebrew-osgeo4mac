class OrfeoIce < Formula
  desc "Interactive raster visualiztion library"
  homepage "http://www.orfeo-toolbox.org/otb/"
  url "https://www.orfeo-toolbox.org/packages/archives/Ice/Ice-0.4.1.tar.gz"
  sha256 "4abb85bcd26766edee827c468e8994e8f3207ce7f1f229f9ce07eb31805ab98b"
  revision 2

  # bottle do
  #   root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "cmake" => :build
  depends_on "orfeo5"
  depends_on "homebrew/science/insighttoolkit"
  depends_on "glew"
  depends_on "glfw"
  depends_on "x11"

  def install
    args = std_cmake_args
    args << "-DCMAKE_PREFIX_PATH=#{Formula["orfeo5"].opt_prefix};#{Formula["insighttoolkit"].opt_prefix}"

    args << "-DGLUT_INCLUDE_DIR=#{MacOS::X11.include}"
    args << "-DGLUT_glut_LIBRARY=#{MacOS::X11.lib/"libglut.dylib"}"

    mkdir "build" do
      system "cmake", "..", *args
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      system "make" # keep as a separate step, or 9000+ symlinks added to orfeo formula
      system "make", "install"
    end
  end

  test do
    #
  end
end
