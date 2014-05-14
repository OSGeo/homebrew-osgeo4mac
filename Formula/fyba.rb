require "formula"

class Fyba < Formula
  homepage "https://github.com/kartverket/fyba"
  # TODO: remove temp hash url after first tagged release
  url "https://github.com/kartverket/fyba.git",
      :revision => "d23b92f00ad9f4b49347b490ebcb284a34c4fa3b"
  version "0.0.1"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    # fixup some includes: https://github.com/kartverket/fyba/issues/12
    # done with inreplace due to CRLF endings in src/UT files
    %W[configure configure.ac src/UT/DISKINFO.cpp src/UT/INQSIZE.cpp src/UT/INQTID.cpp].each do |s|
      inreplace s, "sys/vfs.h", "sys/mount.h"
    end

    system "autoreconf", "-vfi"

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
