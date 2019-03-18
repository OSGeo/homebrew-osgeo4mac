class OsgeoFcgiDebug < Formula
  desc "Helps trace FastCGI programs without having to strace them"
  homepage "http://redmine.lighttpd.net/projects/fcgi-debug/wiki"
  url "https://github.com/lighttpd/fcgi-debug/archive/fcgi-debug-0.9.3.tar.gz"
  sha256 "b63f89c563c05c2a8beb0d2dbace893928291f8f7a7ae651ff7a328a8be64725"

  revision 1

  head "https://github.com/lighttpd/fcgi-debug.git", branch: "master"

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
