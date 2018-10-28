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
    sha256 "f317ec74d95276905f729cae0bc2703a5c5892858801ba1c5422b5fb4d5f624e" => :high_sierra
    sha256 "f317ec74d95276905f729cae0bc2703a5c5892858801ba1c5422b5fb4d5f624e" => :sierra
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
