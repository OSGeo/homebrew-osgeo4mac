class OsgeoLazPerf < Formula
  desc "Alternative LAZ implementation for C++ and JavaScript"
  homepage "https://github.com/hobu/laz-perf"
  url "https://github.com/hobu/laz-perf/archive/1.3.0.tar.gz"
  sha256 "9d4273206557e091a4faf7faa4867ecd7da55a116015fcbfb58d30e88570958e"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "7b02a955661953ec73411efaa516147d67e2376b3a81ce735fa7006bf3aee116" => :mojave
    sha256 "7b02a955661953ec73411efaa516147d67e2376b3a81ce735fa7006bf3aee116" => :high_sierra
    sha256 "b185161a85e97816ae429781856862ef8ddd330716369132ae2b8d0ae0e0bd9d" => :sierra
  end

  revision 1

  head "https://github.com/hobu/laz-perf.git", :branch => "master"

  depends_on "cmake" => :build

  def install
    ENV.cxx11

    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    # TODO
  end
end
