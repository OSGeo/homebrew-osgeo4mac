class OsgeoNitro < Formula
  desc "Library reading/writing the National Imagery Transmission Format (NITF)."
  homepage "https://github.com/hobu/nitro"
  url "https://github.com/hobu/nitro/archive/2.7dev-5.tar.gz"
  version "2.7dev-5"
  sha256 "836433f8937e1598310d53f285c79784c63bd54677e8973b276c4ce9f5251b94"

  head "https://github.com/hobu/nitro.git", :branch => "master"

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
