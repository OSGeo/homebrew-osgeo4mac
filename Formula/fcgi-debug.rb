class FcgiDebug < Formula
  desc "Helps trace FastCGI programs without having to strace them"
  homepage "http://redmine.lighttpd.net/projects/fcgi-debug/wiki"
  url "https://github.com/lighttpd/fcgi-debug/archive/fcgi-debug-0.9.3.tar.gz"

  head "https://github.com/lighttpd/fcgi-debug.git", branch: "master"

  depends_on "cmake" => :build
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
end
