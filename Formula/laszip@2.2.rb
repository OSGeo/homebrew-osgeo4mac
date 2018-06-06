class LaszipAT22 < Formula
  desc "Lossless LiDAR compression"
  homepage "https://www.laszip.org/"
  url "https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz"
  sha256 "b8e8cc295f764b9d402bc587f3aac67c83ed8b39f1cb686b07c168579c61fbb2"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "76b6613dc66169e90b3a8857f0c24bc2f7601a9659b186619074088ee47046e5" => :high_sierra
    sha256 "76b6613dc66169e90b3a8857f0c24bc2f7601a9659b186619074088ee47046e5" => :sierra
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system bin/"laszippertest"
  end
end
