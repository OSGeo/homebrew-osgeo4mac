class LiblasGdal2 < Formula
  desc "C/C++ library for reading and writing the LAS LiDAR format"
  homepage "https://liblas.org/"
  url "http://download.osgeo.org/liblas/libLAS-1.8.1.tar.bz2"
  sha256 "9adb4a98c63b461ed2bc82e214ae522cbd809cff578f28511122efe6c7ea4e76"
  head "https://github.com/libLAS/libLAS.git"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "ffdce4c282c815439a5e2109d7113e6feea3a95a9692f28e464923aa5deef33f" => :sierra
    sha256 "ffdce4c282c815439a5e2109d7113e6feea3a95a9692f28e464923aa5deef33f" => :high_sierra
  end

  keg_only "other version built against older gdal is in main tap"

  option "with-test", "Verify during install with `make test`"

  depends_on "cmake" => :build
  depends_on "libgeotiff"
  depends_on "gdal2"
  depends_on "boost"
  depends_on "laszip" => :optional

  # Fix build for Xcode 9 with upstream commit
  # Remove in next version
  patch do
    url "https://github.com/libLAS/libLAS/commit/49606470.patch?full_index=1"
    sha256 "5590aef61a58768160051997ae9753c2ae6fc5b7da8549707dfd9a682ce439c8"
  end

  resource "laszip" do
    # newest older laszip version that still has include/laszip/laszip.hpp
    url "https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz"
    sha256 "b8e8cc295f764b9d402bc587f3aac67c83ed8b39f1cb686b07c168579c61fbb2"
  end

  def install
    if build.with? "laszip"
      resource("laszip").stage do
        args = std_cmake_args
        args << "-DCMAKE_INSTALL_PREFIX=#{libexec}/laszip"
        mkdir "build" do
          system "cmake", "..", *args
          system "make", "install"
        end
        (libexec/"laszip").install "AUTHORS", "COPYING", "NEWS", "README"
      end
    end

    mkdir "macbuild" do
      # CMake finds boost, but variables like this were set in the last
      # version of this formula. Now using the variables listed here:
      #   https://liblas.org/compilation.html
      ENV["Boost_INCLUDE_DIR"] = "#{HOMEBREW_PREFIX}/include"
      ENV["Boost_LIBRARY_DIRS"] = "#{HOMEBREW_PREFIX}/lib"
      args = ["-DWITH_GEOTIFF=ON", "-DWITH_GDAL=ON"] + std_cmake_args
      if build.with? "laszip"
        args << "-DWITH_LASZIP=ON"
        args << "-DLASZIP_INCLUDE_DIR=#{libexec}/laszip/include"
        args << "-DLASZIP_LIBRARY=#{libexec}/laszip/lib/liblaszip.dylib"
      end

      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.bottle? || build.with?("test")
      system "make", "install"
    end
  end

  test do
    system bin/"liblas-config", "--version"
    system libexec/"laszip/bin/laszippertest" if build.with? "laszip"
  end
end
