require 'formula'

class Orfeo40 < Formula
  homepage 'http://www.orfeo-toolbox.org/otb/'
  url 'http://www.orfeo-toolbox.org/packages/OTB-4.0.0.tgz'
  sha1 'c2417cc4d11544fb477007e06d3a82a032353c95'

  option "with-external-boost", "Build with brewed Boost"
  option 'examples', 'Compile and install various examples'
  option 'java', 'Enable Java support'
  option 'patented', 'Enable patented algorithms'

  depends_on 'cmake' => :build
  depends_on "boost" if build.with? "external-boost"
  depends_on :python => :optional
  depends_on 'gdal'
  depends_on 'qt'
  depends_on "muparser"
  depends_on "libkml"
  depends_on "minizip"
  depends_on "tinyxml"
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  depends_on "opencv" => :optional
  # external libs that may work in next release:
  #depends_on "open-scene-graph" # (for libOpenThreads, now internal to osg)

  conflicts_with "orfeo", :because => "orfeo is in main tap"

  resource "geoid" do
    # geoid to use in elevation calculations, if no DEM defined or avialable
    url "http://hg.orfeo-toolbox.org/OTB-Data/raw-file/dec1ce83a5f3/Input/DEM/egm96.grd"
    sha1 "034ae375ff41b87d5e964f280fde0438c8fc8983"
    version "4.0.0"
  end

  def patches
  end

  def install
    (libexec/"default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DOTB_USE_EXTERNAL_ITK=OFF
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
    args << "-DITK_USE_FFTWF=" + ((build.with? "fftw") ? "ON" : "OFF")
    args << "-DITK_USE_FFTWD=" + ((build.with? "fftw") ? "ON" : "OFF")
    args << "-DITK_USE_SYSTEM_FFTW=" + ((build.with? "fftw") ? "ON" : "OFF")
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
