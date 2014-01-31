require "formula"

class Hexer < Formula
  homepage "https://github.com/hobu/hexer"
  url "https://github.com/hobu/hexer/archive/1.0.1.tar.gz"
  sha1 "dc4e817c89c44740f13f461b52b8f320ea3c7d1a"

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
