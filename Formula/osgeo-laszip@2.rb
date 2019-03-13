class OsgeoLaszipAT2 < Formula
  desc "Lossless LiDAR compression"
  homepage "https://www.laszip.org/"
  url "https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz"
  sha256 "b8e8cc295f764b9d402bc587f3aac67c83ed8b39f1cb686b07c168579c61fbb2"

  # revision 1

  head "https://github.com/LASzip/LASzip.git", :tag => "v2.2.0"

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
