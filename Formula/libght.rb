class Libght < Formula
  homepage "https://github.com/pramsey/libght/"
  url "https://github.com/pramsey/libght/archive/v0.1.0.tar.gz"
  sha1 "19104cdba21fabb8d5fad847af1a8e8bcde40b6a"

  head "https://github.com/pramsey/libght.git", :branch => "master"

  option "with-tests", "Run unit tests after build, prior to install"

  depends_on "cmake" => :build
  depends_on "proj"
  depends_on "liblas"
  depends_on "cunit"

  def install
    ENV.libxml2
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      puts %x(test/cu_tester) if build.with? "tests"
      system "make", "install"
    end
  end

  test do
    assert_match "version #{version.to_s[0,3]}", %x(#{bin}/"las2ght")
  end
end
