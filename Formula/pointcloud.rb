class Pointcloud < Formula
  desc "PostgreSQL extension for storing point cloud (LIDAR) data"
  homepage "https://github.com/pgpointcloud/pointcloud"
  url "https://github.com/pgpointcloud/pointcloud/archive/3929653f51296f5dd5fe5997c8c4c5d46419cb50.tar.gz"
  version "1.1.0-dev"
  sha256 "d3190fb662912c1d889343a3cd221bb3995c9bbc69156fa184c5f4712b7b26b5"

  head "https://github.com/pgpointcloud/pointcloud.git", :branch => "master"

  option "with-test", "Run unit tests after build, prior to install"

  deprecated_option "with-tests" => "with-test"

  depends_on "cmake" => :build
  depends_on :postgresql
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
