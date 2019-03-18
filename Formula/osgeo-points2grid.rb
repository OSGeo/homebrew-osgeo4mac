class OsgeoPoints2grid < Formula
  desc "Generate digital elevation models using local griding"
  homepage "https://github.com/CRREL/points2grid"
  url "https://github.com/CRREL/points2grid/archive/1.3.1.tar.gz"
  sha256 "6e2f2d3bbfd6f0f5c2d0c7d263cbd5453745a6fbe3113a3a2a630a997f4a1807"

  # revision 1

  head "https://github.com/CRREL/points2grid.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "curl"
  depends_on "osgeo-gdal"

  def install
    ENV.cxx11

    args = std_cmake_args + %W[-DWITH_GDAL=ON -DWITH_TESTS=ON -DCMAKE_PREFIX_PATH=#{Formula["curl"].opt_prefix}]
    libexec.install "test/data/example.las"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system bin/"points2grid",
           "-i", libexec/"example.las",
           "-o", "example",
           "--max", "--output_format", "grid"
    assert_equal 13, File.read("example.max.grid").scan("423.820000").size
  end
end
