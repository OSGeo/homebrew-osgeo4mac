class LaszipAT22 < Formula
  desc "Lossless LiDAR compression"
  homepage "https://www.laszip.org/"
  url "https://github.com/LASzip/LASzip/archive/v2.2.0.tar.gz"
  sha256 "b8e8cc295f764b9d402bc587f3aac67c83ed8b39f1cb686b07c168579c61fbb2"

  bottle do
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build

  resource "cpp_example" do
    url "https://raw.githubusercontent.com/LASzip/LASzip/master/example/laszipdllexample.cpp"
    sha256 "5e27b48338095b2570c2e6554aaf95a015b0ab0c5c0a6438b7b21e1202559535"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    resource("cpp_example").stage do
      system ENV.cxx, "laszipdllexample.cpp", "-L#{lib}",
                    "-llaszip", "-llaszip_api", "-Wno-format", "-o", "test"
    assert_match "LASzip DLL", shell_output("./test -h 2>&1", 1)

    end
  end
end
