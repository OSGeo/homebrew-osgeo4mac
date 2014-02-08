require "formula"

class Monteverdi2 < Formula
  homepage "http://orfeo-toolbox.org/otb/monteverdi.html"
  url "http://downloads.sourceforge.net/project/orfeo-toolbox/Monteverdi2-0.6.0.tgz"
  sha1 "0b50a03ec91d166d83621701303f55529543efc9"

  depends_on "cmake" => :build
  depends_on "orfeo"
  depends_on "qt"
  depends_on :x11
  depends_on "fftw"
  depends_on "gdal"
  depends_on "fltk"
  depends_on "liblas"
  depends_on "libkml"
  depends_on "minizip"
  depends_on "tinyxml"
  depends_on "libpqxx"

  resource "qwt5" do
    # http://qwt.sourceforge.net/
    url "http://sourceforge.net/projects/qwt/files/qwt/5.2.3/qwt-5.2.3.tar.bz2"
    sha1 "ff81595a1641a8b431f98d6091bb134bc94e0003"
  end

  def install
    # locally vendor older qwt 5.2.3
    qwt5 = prefix/"qwt5"
    qwt5.mkpath
    resource("qwt5").stage do
      inreplace "qwtconfig.pri" do |s|
        s.sub! "/usr/local/qwt-$$VERSION", qwt5
        s.sub! /(doc.path)/, "#\\1"
        s.sub! /\+(=\s*QwtDesigner)/, "-\\1"
      end
      system "qmake", "-config", "release"
      system "make", "install"
      system "install_name_tool", "-id",
             "#{qwt5}/lib/libqwt.5.dylib",
             "#{qwt5}/lib/libqwt.5.dylib"
    end

    args = std_cmake_args + %W[
      -DCMAKE_PREFIX_PATH=#{qwt5}
    ]

    mkdir "build" do
      system "cmake", "..", *args
      #system "bbedit", "CMakeCache.txt"
      #raise
      system "make"
      system "make", "install"
    end

    # TODO: make .app bundle and embed some env vars
    #       GDAL_DATA=HB/share/gdal
    #       ITK_AUTOLOAD_PATH=HB/opt/orfeo/lib/otb/applications
    # NOTE: see <src>/Packaging for bundling scripts
  end

end
