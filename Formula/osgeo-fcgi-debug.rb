class OsgeoFcgiDebug < Formula
  desc "Helps trace FastCGI programs without having to strace them"
  homepage "http://redmine.lighttpd.net/projects/fcgi-debug/wiki"
  url "https://github.com/lighttpd/fcgi-debug/archive/fcgi-debug-0.9.3.tar.gz"
  sha256 "b63f89c563c05c2a8beb0d2dbace893928291f8f7a7ae651ff7a328a8be64725"

  revision 1

  head "https://github.com/lighttpd/fcgi-debug.git", branch: "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "674bace0a4d665e202d85b1179a60e2dd6987ca6540b16b2b5fc89656175b6a4" => :mojave
    sha256 "674bace0a4d665e202d85b1179a60e2dd6987ca6540b16b2b5fc89656175b6a4" => :high_sierra
    sha256 "2533dc7a2c288f6638e3996c64506543fb495cf8cffd27b165ff8d79b15d4065" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libev"
  depends_on "glib"

  def install
    man1.install "fcgi-debug.1"
    args = std_cmake_args

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    # TODO
  end
end
