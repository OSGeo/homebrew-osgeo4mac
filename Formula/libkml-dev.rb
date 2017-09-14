class LibkmlDev < Formula
  desc "Library to parse, generate and operate on KML (development version)"
  homepage "https://code.google.com/archive/p/libkml/"
  url "https://github.com/google/libkml/archive/8609edf7c8d13ae2ddb6eac2bca7c8e49c67a5f8.tar.gz"
  version "1.3-dev"
  sha256 "667cd86b7e66e38c71c054526e49c6ee9558b506c9ddec9e6de14b87e18c0072"

  bottle do
    root_url "http://qgis.dakotacarto.com/bottles"
    cellar :any
    sha256 "cdc3359b7b7142399d310454743f9c1eb2bf45a8b9d1da2b812cf212931bae25" => :sierra
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
