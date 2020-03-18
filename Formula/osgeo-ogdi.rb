class OsgeoOgdi < Formula
  desc "Open Geographic Datastore Interface - client/server API for GIS"
  homepage "https://ogdi.sourceforge.io/"
  url "https://github.com/libogdi/ogdi/archive/ogdi_4_1_0.tar.gz"
  sha256 "e0b9c6ca37f983f21b45116126d153c0b5609954568fddc306568e204a10e41c"

  revision 3

  head "https://github.com/libogdi/ogdi.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "ababf3d3d5a8cd1e511352707ccae78de4adb5cd16cdd6a85e1239d187b2c49d" => :catalina
    sha256 "ababf3d3d5a8cd1e511352707ccae78de4adb5cd16cdd6a85e1239d187b2c49d" => :mojave
    sha256 "ababf3d3d5a8cd1e511352707ccae78de4adb5cd16cdd6a85e1239d187b2c49d" => :high_sierra
  end

  # depends_on "autoconf" => :build
  # depends_on "automake" => :build
  # depends_on "libtool" => :build
  depends_on "osgeo-proj"
  depends_on "zlib"
  depends_on "expat"

  # resource "ogdits-suite" do
  #   url "https://downloads.sourceforge.net/project/ogdi/OGDI_Test_Suite/3.1/ogdits-3.1.0.tar.gz"
  #   sha256 "55fcf3793ce80858cb02a94d78c7a95990e12197404bfd2178c0100a4f79f4a3"
  # end

  def install
    # --with-proj=ARG       Utilize external PROJ.4 support
    # --with-projlib=path     Select PROJ.4 library
    # --with-projinc=path     Select PROJ.4 include directory
    # --with-zlib=ARG       Utilize external ZLIB support
    # --with-zliblib=path     Select ZLIB library
    # --with-zlibinc=path     Select ZLIB include directory
    # --with-expat=ARG      Utilize external Expat library, or disable Expat.
    # --with-expatlib=path    Select Expat library
    # --with-expatinc=path    Select Expat include directory
    # --with-pkgconfigdir     Use the specified pkgconfig dir (default is
    #                         libdir/pkgconfig)

    args = %W[
      --prefix=#{prefix}
      --with-proj=#{Formula["osgeo-proj"].opt_prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
      --with-expat=#{Formula["expat"].opt_prefix}
      --with-zlib=#{Formula["zlib"].opt_prefix}
    ]

    # Reset ARCHFLAGS to match how we build.
    # ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    ENV.deparallelize
    ENV["TOPDIR"] = Dir.pwd

    # FIXME: ./configure fails on ogdi test compilation due to missing rpc/types.h include
    # use: https://www.gnu.org/software/autoconf/manual/autoconf-2.64/html_node/Present-But-Cannot-Be-Compiled.html
    # then, run autoconf
    # see below fixes for rpc/types.h (does the same for ./configure)

    # rename overridden rules, to avoid copius warnings
    inreplace "#{Dir.pwd}/config/unix.mak" do |s|
      s.sub! /ARCHGEN/, "BLAH_\\1"
      s.sub! /DYNAGEN/, "BLAH_\\1"
    end

    # rename included makefile, otherwise overwritten by `uname`.mak output
    cp "#{Dir.pwd}/config/darwin.mak", "#{Dir.pwd}/config/macos.mak"

    # force overwriting of default makefile to macOS-specific
    inreplace "#{Dir.pwd}/config/generic.mak.in",
              "unix.mak",
              "macos.mak"

    # stub 'bool' typedef reassignment, otherwise get following error...
    #
    # ../rpf.h:77:24: error: cannot combine with previous 'char' declaration specifier
    # typedef unsigned char  bool;
    #                        ^
    # <sdk-path>lib/clang/8.0.0/include/stdbool.h:31:14: note: expanded from macro 'bool'
    # #define bool _Bool
    #
    inreplace "#{Dir.pwd}/ogdi/driver/rpf/rpf.h" do |s|
      s.sub! /(typedef unsigned char +bool;)/, "// \\1"
    end

    # add rpc/types.h prior to other rpc includes that are missing it natively
    # note: referenced rpc headers are in /usr/include/, so can't "fix" them due to SIP
    inreplace "#{Dir.pwd}/ogdi/gltpd/asyncsvr.c" do |s|
      s.sub! %r{(#( +)include <rpc/pmap_clnt\.h>)}, "#\\2include <rpc/types.h>\n\\1"
    end
    inreplace "#{Dir.pwd}/include/Linux/ogdi_macro.h" do |s|
      s.sub! "<wait.h>", "<sys/wait.h>"
      s.sub! %r{(#include <rpc/xdr\.h>)}, "#include <rpc/types.h>\n\\1"
    end
    ENV.append_to_cflags "-I#{Dir.pwd}/include/Linux"

    # FIXME: .dylibs need built for macOS
    #   .dylib files are not versioned, with unversioned symlinks pointing to them
    #   .dylib files have no compatibility or current version embedded

    # raise

    # system "autoreconf", "-fvi"
    system "./configure", *args

    system "make"
    system "make", "install"

    # TODO: fix up for test suite:
    #  'ogdi_info'; use install_name_tool to add rpath to opt_lib/ogdi (OR, link all .dylibs directly?)

    # create symlinks from .so to .dylib files
    # (ogdi_info and libs dynamically finds only .so files)
    Pathname.glob("#{lib}/ogdi/*.dylib") do |dl|
      (lib/"ogdi").install_symlink dl.basename => "#{dl.basename(".dylib")}.so"
    end

    # FIXME: ogdi_info crashes with:
    # ogdi_info(52269,0x...) malloc: *** error for object 0x...: pointer being freed was not allocated
    # something needds changed in its src code
    # NOTE: GDAL/OGR driver still seems to work, just not this ogdi_info utility
  end

  test do
    # resource("ogdits-suite").stage do
    #   # TODO: customize setup.sh
    #   #       add: TEST_DATA=$(dirname $(pwd -P))/data
    #
    #   cd "scripts" do
    #     system "full_test.sh"
    #   end
    # end
  end
end
