class Grass70 < Formula
  desc "Geographic Resources Analysis Support System"
  homepage "http://grass.osgeo.org/"

  stable do
    url "https://grass.osgeo.org/grass70/source/grass-7.0.4.tar.gz"
    sha256 "657188dc640b8482d16f889ff281abe424a0b232d03328086ba28cbf02c65af2"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    patch :DATA
  end

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha256 "bb240ec7666eb963c4642913d067a8225b7e644d41eea14a74f441dc92c53275" => :mavericks
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available."
  option "with-gdal-1", "Build with GDAL/OGR v1.x instead of v2.x"

  # TODO: test on 10.6 first. may work with latest wxWidgets 3.0
  # depends on :macos => :lion
  # TODO: builds with clang (has same non-fatal errors as gcc), but is it compiled correctly?
  # depends on "gcc" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  if build.with? "gdal-1"
    depends_on "gdal"
  else
    depends_on "gdal2"
  end
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on :python
  depends_on "wxpython"
  depends_on "postgresql" => :optional
  depends_on "mysql" => :optional
  depends_on "cairo"
  depends_on "ghostscript" # for cartographic composer previews
  depends_on "x11" # needs to find at least X11/include/GL/gl.h
  depends_on "openblas" => :optional
  depends_on "liblas" => :optional
  depends_on "netcdf" => :optional
  depends_on "ffmpeg" => :optional

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
  end

  def install
    readline = Formula["readline"]
    gettext = Formula["gettext"]

    # noinspection RubyLiteralArrayInspection
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
      "--with-proj-share=#{Formula["proj"].opt_share}/proj",
      "--with-png",
      "--with-readline-includes=#{readline.opt_include}",
      "--with-readline-libs=#{readline.opt_lib}",
      "--with-readline",
      "--with-nls-includes=#{gettext.opt_include}",
      "--with-nls-libs=#{gettext.opt_lib}",
      "--with-nls",
      "--with-freetype",
      "--without-tcltk", # Disabled due to compatibility issues with OS X Tcl/Tk
      "--with-includes=#{gettext.opt_include}"
    ]

    unless MacOS::CLT.installed?
      # On Xcode-only systems (without the CLT), we have to help:
      args << "--with-macosx-sdk=#{MacOS.sdk_path}"
      args << "--with-opengl-includes=#{MacOS.sdk_path}/System/Library/Frameworks/OpenGL.framework/Headers"
    end

    if headless?
      args << "--without-wxwidgets"
    else
      wx_paths = formula_site_packages "wxpython"
      ENV.prepend("PYTHONPATH", wx_paths, File::PATH_SEPARATOR) if wx_paths
      args << "--with-wxwidgets=#{Formula["wxmac"].opt_bin}/wx-config"
    end

    args << "--enable-64bit" if MacOS.prefer_64_bit?
    args << "--with-macos-archs=#{MacOS.preferred_arch}"

    cairo = Formula["cairo"]
    args << "--with-cairo-includes=#{cairo.opt_include}/cairo"
    args << "--with-cairo-libs=#{cairo.opt_lib}"
    args << "--with-cairo"

    # Database support
    args << "--with-postgres" if build.with? "postgresql"

    if build.with? "mysql"
      mysql = Formula["mysql"]
      args << "--with-mysql-includes=#{mysql.opt_include}/mysql"
      args << "--with-mysql-libs=#{mysql.opt_lib}"
      args << "--with-mysql"
    end

    # other optional support
    if build.with? "openblas" # otherwise, Apple's will be found
      openblas = Formula["openblas"]
      args << "--with-blas-includes=#{openblas.opt_include}"
      args << "--with-blas-libs=#{openblas.opt_lib}"
    end

    args << "--with-liblas=#{Formula["liblas"].opt_bin}/liblas-config" if build.with? "liblas"
    args << "--with-netcdf=#{Formula["netcdf"].opt_bin}/nc-config" if build.with? "netcdf"

    if build.with? "ffmpeg"
      ffmpeg = Formula["ffmpeg"]
      args << "--with-ffmpeg-includes=#{(Dir["#{ffmpeg.opt_include}/*"]).join(" ")}"
      args << "--with-ffmpeg-libs=#{ffmpeg.opt_lib}"
      args << "--with-ffmpeg"
    end

    if MacOS.version >= :el_capitan
      # handle stripping of DYLD_* env vars by SIP when passed to utilities;
      # HOME env var is .brew_home during build, so it is still checked for lib
      ln_sf "#{buildpath}/dist.x86_64-apple-darwin#{`uname -r`.strip}/lib", ".brew_home/lib"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make", "GDAL_DYNAMIC=" # make and make install must be separate steps.
    system "make", "GDAL_DYNAMIC=", "install" # GDAL_DYNAMIC set to blank for r.external compatability

    # ensure QGIS's Processing plugin recognizes install
    ln_sf "../bin/grass70", prefix/"grass-#{version}/grass70.sh"
    # link so settings in external apps don't need updated on grass version bump
    # in QGIS Processing options, GRASS folder = HOMEBREW_PREFIX/opt/grass-70/grass-base
    ln_sf "grass-#{version}", prefix/"grass-base"
  end

  def formula_site_packages(f)
    `python -c "import os, sys, site; sp1 = list(sys.path); site.addsitedir('#{Formula[f].opt_lib}/python2.7/site-packages'); print(os.pathsep.join([x for x in sys.path if x not in sp1]))"`.strip
  end

  def caveats
    if headless?
      <<~EOS
        This build of GRASS has been compiled without the WxPython GUI.

        The command line tools remain fully functional.
        EOS
    end
  end

  test do
    system bin/"grass70", "--version"
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
 
