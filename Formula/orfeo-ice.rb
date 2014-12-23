class OrfeoIce < Formula
  ORFEO = "orfeo-42"
  OREFO_F = Formula[ORFEO]
  ORFEO_OPTS = Tab.for_formula(OREFO_F).used_options
  ITK_VER = "4.6"

  homepage "http://www.orfeo-toolbox.org/otb/"
  # url "http://hg.orfeo-toolbox.org/Ice/archive/7ebb3feefb43.tar.gz" # 2014-10-28 commit
  # sha1 "cabab57664559cce9a444f3a8096fe7f6ec2f598"
  url "https://downloads.sourceforge.net/project/orfeo-toolbox/Monteverdi2/Monteverdi2-0.8/Ice-bde0f85ca45d.tgz"
  version "0.2.0"
  sha1 "283c7b969bf345cbf9b986bdc72bbb5ee38e54f4"

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha1 "1c481a12af0abe84b23b913de74c491df202c931" => :mavericks
  end

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
end
