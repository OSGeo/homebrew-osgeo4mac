class OsgeoLibght < Formula
  desc "GeoHashTree for storing and accessing multi-dimensional point clouds"
  homepage "https://github.com/pramsey/libght"
  url "https://github.com/pramsey/libght/archive/e323c506b4180bb6de825c5d637f21f569da4cb4.tar.gz"
  sha256 "43a5b2909234fecdba17ecfc93ab6d254b14cdf0dac48d17d1481ac2d8e398b4"
  version "0.1.1"

  revision 3

  head "https://github.com/pramsey/libght.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "c9ee3b2d00ad53ec24ae6d670c03e53a3c5229875d3ae0797edd8c6fea9ea9b0" => :mojave
    sha256 "c9ee3b2d00ad53ec24ae6d670c03e53a3c5229875d3ae0797edd8c6fea9ea9b0" => :high_sierra
    sha256 "af246921f6cb0e3fcb594eaae4d298b9caf21a5f77c1235dda36ed7350cb4623" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "osgeo-proj"
  depends_on "osgeo-liblas"
  depends_on "cunit"

  def install

    # support for PROJ 6
    # ENV.append_to_cflags "-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H"

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
