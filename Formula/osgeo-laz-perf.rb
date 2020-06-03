class OsgeoLazPerf < Formula
  desc "Alternative LAZ implementation for C++ and JavaScript"
  homepage "https://github.com/hobu/laz-perf"
  url "https://github.com/hobu/laz-perf/archive/1.4.4.zip"
  sha256 "9801e671ac7122bfa67436d8ed3b202323c4f05f467882fe54ae1f20c4f0df88"
  #url "https://github.com/hobu/laz-perf.git",
  #  :branch => "master",
  #  :commit => "834629e362d8ff90669dcec60bef5cf555d197e2"
  #version "1.4.4"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any_skip_relocation
    sha256 "c7cdfafb3568e4381c0322f56af26cfe9660c796d15dc78f7e46931a18305aae" => :catalina
    sha256 "c7cdfafb3568e4381c0322f56af26cfe9660c796d15dc78f7e46931a18305aae" => :mojave
    sha256 "c7cdfafb3568e4381c0322f56af26cfe9660c796d15dc78f7e46931a18305aae" => :high_sierra
  end

  #revision 1

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
