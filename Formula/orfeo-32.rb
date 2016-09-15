require 'formula'

class Orfeo32 < Formula
  homepage 'http://www.orfeo-toolbox.org/otb/'
  url 'https://downloads.sourceforge.net/project/orfeo-toolbox/OTB/OTB-3.20/OTB-3.20.0.tgz'
  sha256 '0b7ae22aca430b357457b0878cf6d0c62b7a0eb27b6e3368b8012de054fd726fsha'

  option "with-external-boost", "Build with brewed Boost"

  keg_only "Older version; orfeo is in main tap and installs same components"

  depends_on 'cmake' => :build
  depends_on "boost" if build.with? "external-boost"
  depends_on :python => :optional
  depends_on 'fltk'
  depends_on 'gdal'
  depends_on 'qt'
  depends_on "muparser"
  depends_on "liblas" # support removed in v4.0, but still functional here
  depends_on "libkml"
  depends_on "minizip"
  depends_on "tinyxml"
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "opencv" => :optional

  option 'examples', 'Compile and install various examples'
  option 'java', 'Enable Java support'
  option 'patented', 'Enable patented algorithms'

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "http://hg.orfeo-toolbox.org/OTB-Data/raw-file/dec1ce83a5f3/Input/DEM/egm96.grd"
    sha256 "2babe341e8e04db11447e823ac0dfe4b17f37fd24c7966bb6aeab85a30d9a733"
    version "3.20.0"
  end

  patch do
    # Fix some CMake modules
    #   Ensure external liblas_c and liblas are found on Mac
    #   Ensure external libOpenThreads is not used unless specified; otherwise it
    #   may use open-scene-graph's newer lib, which fails when linking with orfeo
    url "https://gist.github.com/dakcarto/8890690/raw/ab16c6cbaf7d214b786583f456d8839585a04fa7/orfeo-cmake-fixes.diff"
    sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  end

  patch do
    if MacOS.version >= :mavericks
      # Fix for forward declaration (and other issues) with clang and libc++
      #   See https://groups.google.com/forum/#!topic/otb-users/dRjdIxlDWfs
      url "https://gist.github.com/dakcarto/8930966/raw/331cca49a8e8dd579c4c19c865b17090a7433cd6/orfeo-libc-fixes.diff"
      sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    end
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    # gettext, libpqxx support removed in v4.0, deprecated here
    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DOTB_USE_EXTERNAL_FLTK=ON
      -DBUILD_TESTING=OFF
      -DOTB_USE_EXTERNAL_OPENTHREADS=OFF
      -DOTB_USE_GETTEXT=OFF
      -DOTB_USE_PQXX=OFF
      -DBUILD_SHARED_LIBS=ON
      -DOTB_WRAP_QT=ON
    ]

    args << "-DOTB_USE_EXTERNAL_BOOST=" + ((build.with? "external-boost") ? 'ON' : 'OFF')
    args << '-DBUILD_EXAMPLES=' + ((build.include? 'examples') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_JAVA=' + ((build.include? 'java') ? 'ON' : 'OFF')
    args << '-DOTB_USE_PATENTED=' + ((build.include? 'patented') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_PYTHON=OFF' if build.without? 'python'
    args << "-DUSE_FFTWF=" + ((build.with? "fftw") ? "ON" : "OFF")
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
