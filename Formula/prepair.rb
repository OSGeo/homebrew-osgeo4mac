class Prepair < Formula
  desc "Automatic repair of single GIS polygons using constrained triangulation"
  homepage "https://github.com/tudelft-gist/prepair"
  url "https://github.com/tudelft3d/prepair/archive/v0.7.1.tar.gz"
  sha256 "2abc69588880e595552af363580e38c1a4a63c9d51549f6450ab6f96ee1ad67f"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any
    sha256 "25ac4f4cdb1282e662718e7bf6cb1419d9ae586af842db3ac26bfb9ce1d8848c" => :high_sierra
    sha256 "25ac4f4cdb1282e662718e7bf6cb1419d9ae586af842db3ac26bfb9ce1d8848c" => :sierra
  end

  option "with-library", "Build library in addition to executable"

  depends_on "cmake" => :build
  depends_on "cgal"
  depends_on "gdal2"

  def install
    libexec.install(%w[data icon.png]) # geojson sample data and project icon
    args = std_cmake_args
    mkdir "build" do
      system "cmake", "..", *args
      # system "/usr/local/bin/bbedit", "CMakeCache.txt"
      # raise
      system "make"
      bin.install "prepair"

      if build.with? "library"
        args << "-DAS_LIBRARY=ON"
        system "cmake", "..", *args
        system "make"
        lib.install "libprepair.dylib"
      end
    end
  end

  test do
    mktemp do
      system "#{bin}/prepair", "--shpOut", "--ogr", "#{libexec}/data/CLC2006_180927.geojson"
    end
  end
end
