class Hexer < Formula
  desc "LAS and OGR hexagonal density and boundary surface generation"
  homepage "https://github.com/hobu/hexer"
  url "https://github.com/hobu/hexer/archive/1.4.0.tar.gz"
  sha256 "886134fcdd75da2c50aa48624de19f5ae09231d5290812ec05f09f50319242cb"

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
