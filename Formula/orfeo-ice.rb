class OrfeoIce < Formula
  ORFEO = "orfeo-54".freeze
  OREFO_F = Formula[ORFEO]
  ORFEO_OPTS = Tab.for_formula(OREFO_F).used_options
  ITK_VER = "4.10".freeze

  desc "Interactive raster visualiztion library"
  homepage "http://www.orfeo-toolbox.org/otb/"
  url "https://www.orfeo-toolbox.org/packages/archives/Ice/Ice-0.4.1.tar.gz"
  sha256 "4abb85bcd26766edee827c468e8994e8f3207ce7f1f229f9ce07eb31805ab98b"

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "cmake" => :build
  depends_on ORFEO
  depends_on "glew"
  depends_on "glfw3"
  depends_on :x11

  def install
    args = std_cmake_args
    args << "-DGLUT_INCLUDE_DIR=#{MacOS::X11.include}"
    args << "-DGLUT_glut_LIBRARY=#{MacOS::X11.lib/"libglut.dylib"}"

    if ORFEO_OPTS.include? "with-external-itk"
      itk_f = Formula["insighttoolkit"]
      args << "-DITK_DIR=" + itk_f.opt_lib/"cmake/ITK-#{ITK_VER}"
      ENV.append "CXXFLAGS", "-I#{itk_f.opt_include}/ITK-#{ITK_VER}"
    else
      # Custom '-orfeo' suffix to avoid interfering with insighttoolkit formula
      args << "-DITK_DIR=" + OREFO_F.opt_lib/"cmake/ITK-#{ITK_VER}-orfeo"
      # FIXME: why is this needed for orfeo 4.2, but not 4.0?
      ENV.append "CXXFLAGS", "-I#{OREFO_F.opt_include}/otb/Utilities/ITK"
    end

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
