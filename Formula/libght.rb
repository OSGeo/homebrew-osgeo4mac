class Libght < Formula
  desc "GeoHashTree for storing and accessing multi-dimensional point clouds"
  homepage "https://github.com/pramsey/libght/"
  url "https://github.com/pramsey/libght.git",
      :branch => "master",
      :revision => "e323c506b4180bb6de825c5d637f21f569da4cb4"
  version "0.1.1"

  head "https://github.com/pramsey/libght.git", :branch => "master"

  option "with-test", "Run unit tests after build, prior to install"

  deprecated_option "with-tests" => "with-test"

  depends_on "cmake" => :build
  depends_on "proj"
  depends_on "liblas"
  depends_on "cunit"

  def install
    ENV.libxml2
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      puts `test/cu_tester` if build.with? "test"
      system "make", "install"
    end
  end

  test do
    assert_match "version #{version.to_s[0, 3]}", `#{bin}/"las2ght"`
  end
end
