require "formula"

class Hexer < Formula
  homepage "https://github.com/hobu/hexer"
  url "https://github.com/hobu/hexer/archive/1.2.1.tar.gz"
  sha1 "4383216ece7a80492e4203f4224b0b41f6138303"

  head "https://github.com/hobu/hexer.git", :branch => "master"

  option "with-drawing", "Build Cairo-based SVG drawing"

  depends_on "cmake" => :build
  depends_on "gdal" => :recommended
  depends_on "cairo" if build.with? "drawing"

  def install
    args = std_cmake_args
    args << "-DWITH_DRAWING=TRUE" if build.with? "drawing"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "curse", "--version"
  end
end
