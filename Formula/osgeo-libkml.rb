class OsgeoLibkml < Formula
  desc "Library to parse, generate and operate on KML (development version)"
  homepage "https://code.google.com/archive/p/libkml/"
  url "https://github.com/google/libkml/archive/8609edf7c8d13ae2ddb6eac2bca7c8e49c67a5f8.tar.gz"
  sha256 "667cd86b7e66e38c71c054526e49c6ee9558b506c9ddec9e6de14b87e18c0072"
  version "1.3"

  revision 1

  head "https://github.com/google/libkml.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "3fabac80a848cec660adbba3aa0c9965bd03eb3e70e23e464b6706f897b5ccfb" => :mojave
    sha256 "3fabac80a848cec660adbba3aa0c9965bd03eb3e70e23e464b6706f897b5ccfb" => :high_sierra
    sha256 "d142c373ff382e20f8113a3490a595a4b5732d809ad06a95e46539766df3fdc5" => :sierra
  end

  keg_only "older version is in main tap and installs similar components"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    # See main `libkml` formula for info on patches
    inreplace "configure.ac", "-Werror", ""
    inreplace "third_party/Makefile.am" do |s|
      s.sub! /(lib_LTLIBRARIES =) libminizip.la liburiparser.la/, "\\1"
      s.sub! /(noinst_LTLIBRARIES = libgtest.la libgtest_main.la)/,
             "\\1 libminizip.la liburiparser.la"
      s.sub! /(libminizip_la_LDFLAGS =)/, "\\1 -static"
      s.sub! /(liburiparser_la_LDFLAGS =)/, "\\1 -static"
    end

    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # TODO
  end
end
