require "formula"

class Hexer < Formula
  homepage "https://github.com/hobu/hexer"
  # TODO: request a tagged release
  url "https://github.com/hobu/hexer.git", :revision => "01f8a155f5a77ede98573686bad8994ef2fe30f0"
  version "1.0.1-01f8a15"
  sha1 "01f8a155f5a77ede98573686bad8994ef2fe30f0"

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
