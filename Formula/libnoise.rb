require "formula"

class Libnoise < Formula
  homepage "https://github.com/qknight/libnoise"
  url "https://github.com/qknight/libnoise.git",
      :revision => "ea2e5174ccbc4b30ccdb23e9685a18f3fff66596"
  version "1.0.0-cmake"
  revision 1

  option "with-docs", "Install documentation"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"


  def install
    inreplace "doc/CMakeLists.txt", "/usr/share", share if build.with? "docs"

    args = std_cmake_args
    args << "-DBUILD_LIBNOISE_DOCUMENTATION=ON" if build.with? "docs"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
    end
  end

  def caveats; <<-EOS.undent
    This formula is installed from a fork of the main project, which offers a
    a CMake-based install. Original project is located here:

      `http://libnoise.sourceforge.net`

    EOS
  end
end
