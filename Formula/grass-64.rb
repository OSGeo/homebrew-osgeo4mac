require "formula"

class Grass64 < Formula
  homepage "http://grass.osgeo.org/"

  stable do
    url "http://grass.osgeo.org/grass64/source/grass-6.4.3.tar.gz"
    sha1 "925da985f3291c41c7a0411eaee596763f7ff26e"

    # Patches that files are not installed outside of the prefix.
    patch :DATA
  end

  keg_only "grass is in main tap and same-name bin utilities are installed"

  # wxpython deps does not install across
  option "with-gui", "Build with Tcl-Tk interface."

  depends_on "gcc" if MacOS.version >= :mountain_lion
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  depends_on "gdal"
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on "homebrew/dupes/tcl-tk" if build.with? "gui"
  depends_on :postgresql => :optional
  depends_on :mysql => :optional
  depends_on "cairo"
  depends_on :x11  # needs to find at least X11/include/GL/gl.h

  fails_with :clang do
    cause "Multiple build failures while compiling GRASS tools."
  end

  def install
    readline = Formula["readline"].opt_prefix
    gettext = Formula["gettext"].opt_prefix

    #noinspection RubyLiteralArrayInspection
    args = [
      "--disable-debug", "--disable-dependency-tracking",
      "--enable-largefile",
      "--enable-shared",
      "--with-cxx",
      "--without-motif",
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
      "--without-wxwidgets"
    ]

    args << ((build.with? "gui") ? "--with-tcltk" : "--without-tcltk")
    args << "--without-opengl" # just turn off NVIZ

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

  def post_install
    opts = Tab.for_formula(self).used_options
    inreplace "#{bin}/grass64",
              %r[("\$GISBASE/etc/Init\.sh")],
              "\\1 -#{((opts.include? "with-gui") ? "tcltk" : "text")}"
  end

  def caveats
    if build.with? "gui"
      <<-EOS.undent
        This build of GRASS does not support NVIZ visualization.
      EOS
    else
      <<-EOS.undent
        This build of GRASS has been compiled without the GUI.
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
