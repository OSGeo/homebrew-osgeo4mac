class OsgeoLiblas < Formula
  desc "C/C++ library for reading and writing the LAS LiDAR format"
  homepage "https://liblas.org/"
  url "https://github.com/libLAS/libLAS/archive/09d45518776489508f34098f1c159f58b856f459.tar.gz"
  sha256 "fa2afafb8ec7c81c4216e51de51cf845c99575e7d6efbd22ad311ca8a55ce189"
  version "1.8.1"

  revision 3

  head "https://github.com/libLAS/libLAS.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "945bf1d05a49c270084599ea6ecf4815b4b06a5051c2260368c39bb5f9c2fa73" => :mojave
    sha256 "945bf1d05a49c270084599ea6ecf4815b4b06a5051c2260368c39bb5f9c2fa73" => :high_sierra
    sha256 "26c412f8ad8733a1d29e8c4192a3a13fd28434545b7830b3fe4937afe83b63fc" => :sierra
  end

  keg_only "other version built against older gdal is in main tap"

  option "with-test", "Verify during install with `make test`"
  # option "with-laszip", "Build with laszip support"

  depends_on "cmake" => :build
  depends_on "osgeo-libgeotiff"
  depends_on "boost"
  depends_on "zlib"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "osgeo-proj"
  depends_on "libxml2"
  depends_on "osgeo-gdal"
  depends_on "osgeo-laszip@2" # if build.with? "laszip"
  # other: oracle

  # for laszip 3.2.9
  # Failed to open /laszip/include/laszip/laszip.hpp file

  # is built from a more recent commit, the patches are already applied
  # See: https://github.com/libLAS/libLAS/issues/140

  # Fix ambiguous method error when building against GDAL 2.3
  # patch do
  #   url "https://github.com/nickrobison/libLAS/commit/ec10e274ee765aa54e7c71c8b44d2c7494e63804.patch?full_index=1"
  #   sha256 "3f8aefa1073aa32de01175cd217773020d93e5fb44a4592d76644a242bb89a3c"
  # end

  # Fix build for Xcode 9 with upstream commit
  # Remove in next version
  # patch do
  #   url "https://github.com/libLAS/libLAS/commit/49606470.patch?full_index=1"
  #   sha256 "5590aef61a58768160051997ae9753c2ae6fc5b7da8549707dfd9a682ce439c8"
  # end

  # fix for liblas-config
  resource "liblas-config" do
    url "https://gist.githubusercontent.com/fjperini/746634c101b0ffc8926baaf55d5cf793/raw/d6bb4a0732c215a9c62fdb795bdabcf1ae8191ac/liblas-config"
    sha256 "e45e9d99f0ff6f8e2b045ddd46007b7c6b3c6afd3620c36994ae3b54e49b17e7"
    version "1.8.1"
  end

  def install
    ENV.cxx11

    mkdir "macbuild" do
      # CMake finds boost, but variables like this were set in the last
      # version of this formula. Now using the variables listed here:
      #   https://liblas.org/compilation.html
      ENV["Boost_INCLUDE_DIR"] = "#{HOMEBREW_PREFIX}/include"
      ENV["Boost_LIBRARY_DIRS"] = "#{HOMEBREW_PREFIX}/lib"
      args = ["-DWITH_GEOTIFF=ON", "-DWITH_GDAL=ON"] + std_cmake_args

      # if build.with? "laszip"
      args << "-DWITH_LASZIP=ON"
      args << "-DLASZIP_INCLUDE_DIR=#{Formula['osgeo-laszip@2'].opt_include}"
      args << "-DLASZIP_LIBRARY=#{Formula['osgeo-laszip@2'].opt_lib}/liblaszip.dylib"
      # end

      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.bottle? || build.with?("test")
      system "make", "install"

      # fix for liblas-config
      # for some reason it does not build
      bin.install resource("liblas-config")
    end

    # Fix rpath value, to ensure grass7 grabs the correct dylib
    MachO::Tools.change_install_name("#{lib}/liblas_c.3.dylib", "@rpath/liblas.3.dylib", "#{opt_lib}/liblas.3.dylib")
  end

  test do
    system bin/"liblas-config", "--version"
  end
end
