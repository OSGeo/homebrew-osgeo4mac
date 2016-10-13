class Taudem < Formula
  desc "Terrain Analysis Using Digital Elevation Models for hydrology"
  homepage "http://hydrology.usu.edu/taudem/taudem5/"
  url "https://github.com/dtarb/TauDEM/archive/a0335e826d579926013e2d1c33c53d413b7c04b3.tar.gz"
  version "5.3.6-dev"
  sha256 "8b82f5162af6aaa5dcc0d56d23f6a392cfe5463b317ae5286286dba5554160f3"

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   cellar :any
  #   sha256 "" => :mavericks
  # end

  head "https://github.com/dtarb/TauDEM.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on :mpi => [:cc, :cxx]
  depends_on "gdal"

  resource "logan" do
    url "http://hydrology.usu.edu/taudem/taudem5/LoganDemo.zip"
    sha256 "3340f75a30d3043e7ad09b7a7324fa71374811b22fa913ad577840499a7dab83"
    version "5.3.5"
  end

  def install
    args = std_cmake_args
    cd "src" do
      system "cmake", ".", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    resource("logan").stage do
      system "#{opt_prefix}/bin/pitremove", "logan.tif"
    end
  end
end
