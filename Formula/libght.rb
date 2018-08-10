class Libght < Formula
  desc "GeoHashTree for storing and accessing multi-dimensional point clouds"
  homepage "https://github.com/pramsey/libght/"
  url "https://github.com/pramsey/libght.git",
      :branch => "master",
      :revision => "e323c506b4180bb6de825c5d637f21f569da4cb4"
  version "0.1.1"

  head "https://github.com/pramsey/libght.git", :branch => "master"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    sha256 "dd1015999e44dc1478f908a258f17bd2a38e75ac82b81a8e362a34c28ee55a81" => :high_sierra
    sha256 "dd1015999e44dc1478f908a258f17bd2a38e75ac82b81a8e362a34c28ee55a81" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "proj"
  depends_on "liblas-gdal2"
  depends_on "cunit"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    assert_match "version #{version.to_s[0, 3]}", `#{bin}/"las2ght"`
  end
end
