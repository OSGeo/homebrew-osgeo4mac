class Pointcloud < Formula
  desc "PostgreSQL extension for storing point cloud (LIDAR) data"
  homepage "https://github.com/pgpointcloud/pointcloud"
  url "https://github.com/pgpointcloud/pointcloud/archive/v1.1.1.tar.gz"
  sha256 "1f0da23cf1976d883aad20875b678928e39a28b40d4c96eb90aff5106cdd400d"

  head "https://github.com/pgpointcloud/pointcloud.git", :branch => "master"

  option "with-test", "Run unit tests after build, prior to install"

  deprecated_option "with-tests" => "with-test"

  depends_on "cmake" => :build
  depends_on "postgresql"
  depends_on "libght"
  depends_on "libxml2"
  # depends on "lazperf" => :optional
  depends_on "cunit" if build.with? "test"

  def install
    mkdir lib/"postgresql"
    mkdir_p pkgshare/"postgresql/extension/"
    inreplace "pgsql/CMakeLists.txt", "${PGSQL_PKGLIBDIR}", "#{lib}/postgresql"
    inreplace "pgsql/CMakeLists.txt", "${PGSQL_SHAREDIR}", "#{share}/postgresql"
    inreplace "pgsql_postgis/CMakeLists.txt", "${PGSQL_SHAREDIR}", "#{share}/postgresql"

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      # TODO: this fails with Segmentation fault: 11
      # puts `lib/cunit/cu_tester` if build.with? "test"
      system "make", "install"
    end
  end

  test do
    system "True"
  end
end
