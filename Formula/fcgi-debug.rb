require "formula"

class FcgiDebug < Formula
  homepage "http://redmine.lighttpd.net/projects/fcgi-debug/wiki"
  # TODO: remove temp hash url after first tagged release
  url "https://github.com/lighttpd/fcgi-debug.git",
      :revision => "88c9f6a2b098f26d53d46e3d5db5dfafc758fdf1"
  version "0.0.0-88c9f6a"
  sha1 "88c9f6a2b098f26d53d46e3d5db5dfafc758fdf1"

  head "https://github.com/lighttpd/fcgi-debug.git", :branch => "master"

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
