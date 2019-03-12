class OsgeoHdf4 < Formula
  homepage "http://www.hdfgroup.org"
  url "https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.13/src/hdf-4.2.13.tar.gz"
  sha256 "be9813c1dc3712c2df977d4960e1f13f20f447dfa8c3ce53331d610c1f470483"

  option "with-fortran", "Build Fortran interface."
  option "with-tests", "Run the test suite (may fail)"


  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "szip" => :recommended
  depends_on "jpeg"
  depends_on "gcc" if build.with? "fortran"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "be48da2298fb994b4ba96202cd209078e278e69d505d5364470ebddd9acaba94" => :mojave
    sha256 "be48da2298fb994b4ba96202cd209078e278e69d505d5364470ebddd9acaba94" => :high_sierra
    sha256 "be48da2298fb994b4ba96202cd209078e278e69d505d5364470ebddd9acaba94" => :sierra
  end

  resource "test_file" do
    url "https://gamma.hdfgroup.org/ftp/pub/outgoing/h4map/data/CT01_Rank6ArraysTablesAttributesGroups.hdf"
    sha256 "e4a610c95ddd1f2247038adf46de354fe902e72b5b72757322d19c362c0d415a"
  end

  def install
    ENV.O0 # Per the release notes, -O2 can cause memory corruption
    ENV["SZIP_INSTALL"] = HOMEBREW_PREFIX

    args = std_cmake_args
    args.concat [
      "-DBUILD_SHARED_LIBS=ON",
      "-DHDF4_BUILD_TOOLS=ON",
      "-DHDF4_BUILD_UTILS=ON",
      "-DHDF4_BUILD_WITH_INSTALL_NAME=ON",
      "-DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON",
      "-DHDF4_ENABLE_NETCDF=OFF", # Conflict. Just install NetCDF for this.
      "-DHDF4_ENABLE_Z_LIB_SUPPORT=ON"
    ]

    # szip has been reported to break linking with GDAL, so it may need to be disabled if you run into errors.
    if build.with? "szip"
      args.concat %W[-DHDF4_ENABLE_SZIP_ENCODING=ON -DHDF4_ENABLE_SZIP_SUPPORT=ON]
    else
      args << "-DHDF4_ENABLE_SZIP_SUPPORT=OFF"
    end

    if build.with? "fortran"
      args.concat %W[-DHDF4_BUILD_FORTRAN=ON -DCMAKE_Fortran_MODULE_DIRECTORY=#{include}]
    else
      args << "-DHDF4_BUILD_FORTRAN=OFF"
    end

    args << "-DBUILD_TESTING=OFF" if build.without? "tests"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      system "make", "test" if build.with? "tests"

      # Remove stray nc* artifacts which conflict with NetCDF.
      rm (bin+"ncdump")
      rm (bin+"ncgen")
#      rm (include+"netcdf.inc")
    end
  end

  def caveats; <<~EOS
      HDF4 has been superseeded by HDF5.  However, the API changed
      substantially and some programs still require the HDF4 libraries in order
      to function.
    EOS
  end

  test do
    resource("test_file").stage do
      system "#{opt_prefix}/bin/vshow", "CT01_Rank6ArraysTablesAttributesGroups.hdf"
    end
  end

end
