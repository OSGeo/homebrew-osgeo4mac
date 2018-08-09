class Nitro < Formula
  desc "Library reading/writing the National Imagery Transmission Format (NITF)."
  homepage "https://github.com/hobu/nitro"
  url "https://github.com/hobu/nitro/archive/2.7dev-2.tar.gz"
  version "2.7dev-1"
  sha256 "cb00e5bd5d045f1bc333e1e054272c206c9910d008698b9cd7f2d67153a32ee2"

  head "https://github.com/hobu/nitro.git", :branch => "master"

  bottle do
  end

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
