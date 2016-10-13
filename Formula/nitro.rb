class Nitro < Formula
  desc "Library reading/writing the National Imagery Transmission Format (NITF)."
  homepage "https://github.com/hobu/nitro"
  url "https://github.com/hobu/nitro/archive/2.7dev-1.tar.gz"
  version "2.7dev-1"
  sha256 "6c5c403ef5e90f07b3fd6bb425de97eeaefc79a9920a3970541dd9a33b46aca8"

  head "https://github.com/hobu/nitro.git", :branch => "master"

  depends_on "cmake" => :build

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
