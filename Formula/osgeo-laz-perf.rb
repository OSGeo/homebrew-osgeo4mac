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
    sha256 "f2251ec963bfe2db4fcfba2e67a44e28f0c9184a102fdb280ba4185afeb92b83" => :catalina
    sha256 "f2251ec963bfe2db4fcfba2e67a44e28f0c9184a102fdb280ba4185afeb92b83" => :mojave
    sha256 "f2251ec963bfe2db4fcfba2e67a44e28f0c9184a102fdb280ba4185afeb92b83" => :high_sierra
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
