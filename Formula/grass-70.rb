require "formula"

class Grass70 < Formula
  homepage "http://grass.osgeo.org/"

  stable do
    url "http://grass.osgeo.org/grass70/source/grass-7.0.0beta2.tar.gz"
    sha1 "b4a87a2ab7ca9384bd563c9fcbc23b836f96a321"
    version "7.0.0beta2"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    patch :DATA
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available."

  depends_on :macos => :lion
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  depends_on "gdal"
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on "wxpython"
  depends_on :postgresql => :optional
  depends_on :mysql => :optional
  depends_on "cairo"
  depends_on :x11  # needs to find at least X11/include/GL/gl.h

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
      "--without-tcltk", # Disabled due to compatibility issues with OS X Tcl/Tk
      "--with-includes=#{gettext}/include"
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
diff --git a/include/Make/Install.make b/include/Make/Install.make
index cf16788..8c0007b 100644
--- a/include/Make/Install.make
+++ b/include/Make/Install.make
@@ -114,11 +114,6 @@ real-install: | $(INST_DIR) $(UNIX_BIN)
 	-$(INSTALL) config.status $(INST_DIR)/config.status
 	-$(CHMOD) -R a+rX $(INST_DIR) 2>/dev/null
 
-ifneq ($(findstring darwin,$(ARCH)),)
-	@# enable OSX Help Viewer
-	@/bin/ln -sfh "$(INST_DIR)/docs/html" /Library/Documentation/Help/GRASS-$(GRASS_VERSION_MAJOR).$(GRASS_VERSION_MINOR)
-endif
-
 $(INST_DIR) $(UNIX_BIN):
 	$(MAKE_DIR_CMD) $@
 
