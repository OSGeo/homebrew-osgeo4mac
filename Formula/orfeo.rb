require 'formula'

class Orfeo < Formula
  homepage 'http://www.orfeo-toolbox.org/otb/'
  url 'http://downloads.sourceforge.net/project/orfeo-toolbox/OTB/OTB-3.20/OTB-3.20.0.tgz'
  sha1 '2af5b4eb857d0f1ecb1fd1107c6879f9d79dd0fc'

  option "with-external-boost", "Build with brewed Boost"

  depends_on 'cmake' => :build
  depends_on "boost" if build.with? "external-boost"
  depends_on :python => :optional
  depends_on 'fltk'
  depends_on 'gdal'
  depends_on 'qt'
  depends_on "muparser"
  depends_on "liblas" # support removed in v4.0
  depends_on "libkml"
  depends_on "minizip"
  depends_on "tinyxml"
  # external libs that may work in next release:
  #depends_on "open-scene-graph" # (for libOpenThreads, now internal to osg)

  depends_on "fftw" => :optional # restricts built binaries to GPL license
  # these are currently experimental
  depends_on "gettext" => :optional # support removed in v4.0
  depends_on "libpqxx" => :optional # support removed in v4.0
  depends_on "opencv" => :optional

  option 'examples', 'Compile and install various examples'
  option 'java', 'Enable Java support'
  option 'patented', 'Enable patented algorithms'

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "http://hg.orfeo-toolbox.org/OTB-Data/raw-file/dec1ce83a5f3/Input/DEM/egm96.grd"
    sha1 "034ae375ff41b87d5e964f280fde0438c8fc8983"
    version "3.20.0"
  end

  def patches
    # Fix some CMake modules
    # Ensure external liblas_c and liblas are found on Mac
    # Ensure external libOpenThreads is not used unless specified; otherwise it
    # may use open-scene-graph's newer lib, which fails when linking with orfeo
    %W[
      https://gist.github.com/dakcarto/8890690/raw/ab16c6cbaf7d214b786583f456d8839585a04fa7/orfeo-cmake-fixes.diff
    ]
    # Fix for forward declaration (and other issues) with clang and libc++
    #https://gist.github.com/dakcarto/8890703/raw/47a363b483794c595dff83d23e989b9248454de5/orfeo-clang-fixes.diff
  end

  fails_with :clang do
    build 500
    cause <<-EOS.undent
      Due to disallowed forward declarations (and other issues).
      See https://groups.google.com/forum/#!topic/otb-users/dRjdIxlDWfs
      No fix (2014-02-08)
    EOS
  end

  def install
    (share/"orfeo/default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DOTB_USE_EXTERNAL_FLTK=ON
      -DBUILD_TESTING=OFF
      -DOTB_USE_EXTERNAL_OPENTHREADS=OFF
      -DBUILD_SHARED_LIBS=ON
      -DOTB_WRAP_QT=ON
    ]

    args << "-DOTB_USE_EXTERNAL_BOOST=" + ((build.with? "external-boost") ? 'ON' : 'OFF')
    args << '-DBUILD_EXAMPLES=' + ((build.include? 'examples') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_JAVA=' + ((build.include? 'java') ? 'ON' : 'OFF')
    args << '-DOTB_USE_PATENTED=' + ((build.include? 'patented') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_PYTHON=OFF' if build.without? 'python'
    args << "-DUSE_FFTWF=" + ((build.with? "fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_GETTEXT=" + ((build.with? "gettext") ? "ON" : "OFF")
    args << "-DOTB_USE_PQXX=" + ((build.with? "libpqxx") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + ((build.with? "opencv") ? "ON" : "OFF")

    mkdir 'build' do
      system 'cmake', '..', *args
      #system "bbedit", "CMakeCache.txt"
      #raise
      system 'make'
      system 'make install'
    end
  end
end
