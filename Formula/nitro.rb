class Nitro < Formula
  desc "Library reading/writing the National Imagery Transmission Format (NITF)."
  homepage "https://github.com/hobu/nitro"
  url "https://github.com/hobu/nitro/archive/2.7dev-3.tar.gz"
  version "2.7dev-3"
  sha256 "ea4186854b713513b48835eb3d718f3710759e3b367706caef936e3597664f57"

  head "https://github.com/hobu/nitro.git", :branch => "master"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "0452649e8d45d85e1611148dc235c8b7a42f4b859ff0e69a4bcdd14109a3c13f" => :mojave
    sha256 "0452649e8d45d85e1611148dc235c8b7a42f4b859ff0e69a4bcdd14109a3c13f" => :high_sierra
    sha256 "0452649e8d45d85e1611148dc235c8b7a42f4b859ff0e69a4bcdd14109a3c13f" => :sierra
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
