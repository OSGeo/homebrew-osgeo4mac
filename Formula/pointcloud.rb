require "formula"

class Pointcloud < Formula
  homepage "https://github.com/pramsey/pointcloud"
  # functioning CMake build and fixes for Mountain Lion (not in 0.1.0 release)
  url "https://github.com/pramsey/pointcloud.git",
      :revision => "4c4bb5d394b904d3cd4e111c098dea1949b9ec90"
  version "0.2.0-4c4bb5d"
  sha1 "4c4bb5d394b904d3cd4e111c098dea1949b9ec90"

  head "https://github.com/pramsey/pointcloud.git", :branch => "master"

  option "with-tests", "Run unit tests after build, prior to install"

  depends_on "cmake" => :build
  depends_on :postgresql
  depends_on "libght"
  depends_on "cunit" if build.with? "tests"

  def install
    ENV.libxml2
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      puts %x(lib/cunit/cu_tester) if build.with? "tests"
      system "make", "install"
    end
  end
end
