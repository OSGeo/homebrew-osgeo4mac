class OsgeoTaudem < Formula
  desc "Terrain Analysis Using Digital Elevation Models for hydrology"
  homepage "http://hydrology.usu.edu/taudem/taudem5/"
  url "https://github.com/dtarb/TauDEM/archive/bf9417172225a9ce2462f11138c72c569c253a1a.tar.gz"
  sha256 "2adffb82f6c9cdda42c2373f551aefb4d52f444005df961675eaf08f6edcbccc"
  version "5.3.8"

  revision 1

  head "https://github.com/dtarb/TauDEM.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "open-mpi"
  depends_on "osgeo-gdal"

  resource "logan" do
    url "http://hydrology.usu.edu/taudem/taudem5/LoganDemo.zip"
    sha256 "3340f75a30d3043e7ad09b7a7324fa71374811b22fa913ad577840499a7dab83"
    version "5.3.5"
  end

  def install
    ENV.cxx11
    args = std_cmake_args
    cd "src" do
      system "cmake", ".", *args
      system "make"
      system "make", "install"
    end

    mkdir "#{bin}"
    bin.install_symlink Dir["#{prefix}/taudem/*"]
  end

  test do
    resource("logan").stage do
      system "#{opt_prefix}/bin/pitremove", "logan.tif"
    end
  end
end
