class OsgeoLibght < Formula
  desc "GeoHashTree for storing and accessing multi-dimensional point clouds"
  homepage "https://github.com/pramsey/libght"
  url "https://github.com/pramsey/libght/archive/e323c506b4180bb6de825c5d637f21f569da4cb4.tar.gz"
  sha256 "43a5b2909234fecdba17ecfc93ab6d254b14cdf0dac48d17d1481ac2d8e398b4"
  version "0.1.1"

  revision 1

  head "https://github.com/pramsey/libght.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "proj"
  depends_on "osgeo-liblas"
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
