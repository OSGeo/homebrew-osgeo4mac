require 'formula'

class Minizip < Formula
  homepage 'http://www.winimage.com/zLibDll/minizip.html'
  url 'http://zlib.net/zlib-1.2.8.tar.gz'
  sha1 'a4d316c404ff54ca545ea71a27af7dbc29817088'

  # version for minizip, not zlib
  version '1.1'

  option :universal

  depends_on :autoconf => :build
  depends_on :automake => :build
  depends_on :libtool => :build

  depends_on 'homebrew/dupes/zlib'

  conflicts_with 'libkml', :because => 'libkml installs `libminizip.dylib` with custom symbol names'

  def patches
    # Remove -I and -L flags to parent zlib source
    # (allows linking to homebrew/dupes/zlib)
    DATA
  end

  def install
    ENV.universal_binary if build.universal?

    ENV.prepend 'CPPFLAGS', "-I#{Formula.factory('homebrew/dupes/zlib').opt_prefix}/include"
    ENV.prepend 'LDFLAGS', "-L#{Formula.factory('homebrew/dupes/zlib').opt_prefix}/lib"

    Dir.chdir 'contrib/minizip' do
      system "autoreconf", "-fi"
      system "./configure", "--prefix=#{prefix}"
      system "make"
      system "make install"
    end

  end

  def caveats
    <<-EOS.undent
      Minizip headers installed in 'minizip' subdirectory, since they conflict
      with the venerable 'unzip' library.

      If you build your own software and it requires these components,
      you may need to add to your build variables:

      CPPFLAGS:  -I#{HOMEBREW_PREFIX}/include/minizip
      LDFLAGS:   -L#{HOMEBREW_PREFIX}/lib

    EOS
  end
end

__END__
diff --git a/contrib/minizip/Makefile.am b/contrib/minizip/Makefile.am
index d343011..079ab18 100644
--- a/contrib/minizip/Makefile.am
+++ b/contrib/minizip/Makefile.am
@@ -4,11 +4,8 @@ if COND_DEMOS
 bin_PROGRAMS = miniunzip minizip
 endif
 
-zlib_top_srcdir = $(top_srcdir)/../..
-zlib_top_builddir = $(top_builddir)/../..
-
-AM_CPPFLAGS = -I$(zlib_top_srcdir)
-AM_LDFLAGS = -L$(zlib_top_builddir)
+AM_CPPFLAGS =
+AM_LDFLAGS =
 
 if WIN32
 iowin32_src = iowin32.c

