require 'formula'

class Grass70 < Formula
  homepage 'http://grass.osgeo.org/'

  stable do
    url "http://grass.osgeo.org/grass70/source/grass-7.0.0beta1.tar.gz"
    sha1 "3ab5fd111b05b32b1aed0375e45052ee8963a3c1"
    version "7.0.0beta1"

    # Patches that files are not installed outside of the prefix.
    # patch :DATA
  end

  keg_only 'This is a GRASS beta version; also `grass` is in main tap and same-name bin utilities are installed'

  option "without-gui", "Build without WxPython interface. Command line tools still available."

  depends_on :macos => :lion
  # depends_on 'apple-gcc42' if MacOS.version >= :mountain_lion
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  depends_on "gdal"
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on "wxmac" => :recommended # prefer over OS X's version because of 64bit
  depends_on :postgresql => :optional
  depends_on :mysql => :optional
  depends_on "cairo"
  depends_on :x11  # needs to find at least X11/include/GL/gl.h

  # fails_with :clang do
  #   cause "Multiple build failures while compiling GRASS tools."
  # end

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? 'gui'
  end

  def install
    readline = Formula["readline"].opt_prefix
    gettext = Formula["gettext"].opt_prefix

    #noinspection RubyLiteralArrayInspection
    args = [
      "--disable-debug", "--disable-dependency-tracking",
      "--enable-shared",
      "--with-cxx",
      "--with-python",
      "--with-blas",
      "--with-lapack",
      "--with-sqlite",
      "--with-odbc",
      "--with-geos=#{Formula["geos"].opt_bin}/geos-config",
      "--with-png",
      "--with-readline-includes=#{readline}/include",
      "--with-readline-libs=#{readline}/lib",
      "--with-readline",
      "--with-nls-includes=#{gettext}/include",
      "--with-nls-libs=#{gettext}/lib",
      "--with-nls",
      "--with-freetype",
      "--without-tcltk" # Disabled due to compatibility issues with OS X Tcl/Tk
    ]

    unless MacOS::CLT.installed?
      # On Xcode-only systems (without the CLT), we have to help:
      args << "--with-macosx-sdk=#{MacOS.sdk_path}"
      args << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
    end

    if headless? or build.without? 'wxmac'
      args << "--without-wxwidgets"
    else
      wxmac = Formula['wxmac'].opt_prefix
      ENV["PYTHONPATH"] = "#{wxmac}/lib/python2.7/site-packages"
      args << "--with-wxwidgets=#{wxmac}/bin/wx-config"
    end

    args << "--enable-64bit" if MacOS.prefer_64_bit?
    args << "--with-macos-archs=#{MacOS.preferred_arch}"

    cairo = Formula["cairo"]
    args << "--with-cairo-includes=#{cairo.include}/cairo"
    args << "--with-cairo-libs=#{cairo.lib}"
    args << "--with-cairo"

    # Database support
    args << "--with-postgres" if build.with? "postgresql"

    if build.with? "mysql"
      mysql = Formula["mysql"]
      args << "--with-mysql-includes=#{mysql.include}/mysql"
      args << "--with-mysql-libs=#{mysql.lib}"
      args << "--with-mysql"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make GDAL_DYNAMIC=" # make and make install must be separate steps.
    system "make GDAL_DYNAMIC= install" # GDAL_DYNAMIC set to blank for r.external compatability
  end

  def caveats
    if headless?
      <<-EOS.undent
        This build of GRASS has been compiled without the WxPython GUI.

        The command line tools remain fully functional.
        EOS
    end
  end
end

__END__
Remove two lines of the Makefile that try to install stuff to
/Library/Documentation---which is outside of the prefix and usually fails due
to permissions issues.

diff --git a/Makefile b/Makefile
index f1edea6..be404b0 100644
--- a/Makefile
+++ b/Makefile
@@ -304,8 +304,6 @@ ifeq ($(strip $(MINGW)),)
 	-tar cBf - gem/skeleton | (cd ${INST_DIR}/etc ; tar xBf - ) 2>/dev/null
 	-${INSTALL} gem/gem$(GRASS_VERSION_MAJOR)$(GRASS_VERSION_MINOR) ${BINDIR} 2>/dev/null
 endif
-	@# enable OSX Help Viewer
-	@if [ "`cat include/Make/Platform.make | grep -i '^ARCH.*darwin'`" ] ; then /bin/ln -sfh "${INST_DIR}/docs/html" /Library/Documentation/Help/GRASS-${GRASS_VERSION_MAJOR}.${GRASS_VERSION_MINOR} ; fi


 install-strip: FORCE
