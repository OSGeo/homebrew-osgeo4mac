class OsgeoNitro < Formula
  desc "Library reading/writing the National Imagery Transmission Format (NITF)."
  homepage "https://github.com/hobu/nitro"
  url "https://github.com/hobu/nitro/archive/2.7dev-5.tar.gz"
  version "2.7dev-5"
  sha256 "836433f8937e1598310d53f285c79784c63bd54677e8973b276c4ce9f5251b94"

  revision 1

  head "https://github.com/hobu/nitro.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "2cfb9d67e88078462f73c812e7bdf66ea02d20349b6fd2ebf2af132a7346a60c" => :mojave
    sha256 "2cfb9d67e88078462f73c812e7bdf66ea02d20349b6fd2ebf2af132a7346a60c" => :high_sierra
    sha256 "5cc9c36fae4c7d1310cf74aed0d02e8e950884a37aba5c9d4e072623199d73d3" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "llvm" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    # installs just a lib
  end
end
