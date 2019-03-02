class LiblasGdal2 < Formula
  desc "C/C++ library for reading and writing the LAS LiDAR format"
  homepage "https://liblas.org/"
  url "http://download.osgeo.org/liblas/libLAS-1.8.1.tar.bz2"
  sha256 "9adb4a98c63b461ed2bc82e214ae522cbd809cff578f28511122efe6c7ea4e76"

  revision 4

  head "https://github.com/libLAS/libLAS.git"

   bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "27dd07eac404543f67607bfed7a46c4561cd8b6286dfd8e6c84626aeae50c6cb" => :mojave
    sha256 "27dd07eac404543f67607bfed7a46c4561cd8b6286dfd8e6c84626aeae50c6cb" => :high_sierra
    sha256 "27dd07eac404543f67607bfed7a46c4561cd8b6286dfd8e6c84626aeae50c6cb" => :sierra
  end

  keg_only "other version built against older gdal is in main tap"

  option "with-test", "Verify during install with `make test`"
  option "with-laszip", "Build with laszip support"

  depends_on "cmake" => :build
  depends_on "libgeotiff"
  depends_on "gdal2"
  depends_on "boost"
  depends_on "laszip" # or laszip@2.2 # if build.with? "laszip"
  depends_on "zlib"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "proj"

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
        args << "-DLASZIP_INCLUDE_DIR=#{Formula['laszip'].opt_include}"
        args << "-DLASZIP_LIBRARY=#{Formula['laszip'].opt_lib}/liblaszip.dylib"
      # end

      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.bottle? || build.with?("test")
      system "make", "install"
    end

    # Fix rpath value, to ensure grass7 grabs the correct dylib
    MachO::Tools.change_install_name("#{lib}/liblas_c.3.dylib", "@rpath/liblas.3.dylib", "#{opt_lib}/liblas.3.dylib")
  end

  test do
    system bin/"liblas-config", "--version"
  end
end
