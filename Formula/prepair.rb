class Prepair < Formula
  desc "Automatic repair of single GIS polygons using constrained triangulation"
  homepage "https://github.com/tudelft-gist/prepair"
  url "https://github.com/tudelft3d/prepair/archive/417f1bc9c4375bfe293e4c096cadc9911feb6266.tar.gz"
  version "0.8-dev"
  sha256 "cd19877f014ec98737ec0966cf8eacfb27d98627c6e42c7c27b19b97e7b139af"

  option "with-library", "Build library in addition to executable"

  depends_on "cmake" => :build
  depends_on "cgal"
  depends_on "gdal2"

  def install
    libexec.install(%W[data icon.png]) # geojson sample data and project icon
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
