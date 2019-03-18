class OsgeoLazPerf < Formula
  desc "Alternative LAZ implementation for C++ and JavaScript"
  homepage "https://github.com/hobu/laz-perf"
  url "https://github.com/hobu/laz-perf/archive/1.3.0.tar.gz"
  sha256 "9d4273206557e091a4faf7faa4867ecd7da55a116015fcbfb58d30e88570958e"

  # revision 1

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
