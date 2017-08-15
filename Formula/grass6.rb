require File.expand_path("../../Requirements/grass_requirements",
                         Pathname.new(__FILE__).realpath)

class Grass6 < Formula
  desc "Geographic Resources Analysis Support System"
  homepage "http://grass.osgeo.org/"

  stable do
    url "https://grass.osgeo.org/grass64/source/grass-6.4.6.tar.gz"
    sha256 "5a84754614619cc265d843980e28f39a1d24048805b9b2865e76a583d973f333"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # Also, quick patch for compiling with clang (as yet, unreported issue)
    patch :DATA
  end

  bottle do
    # root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    # revision 1
    # sha256 "13723d19221024073a0e781dddf3cbb9ab30e13a3b8d4d50c6eb61d0e60c347f" => :mavericks
    # sha256 "f951bfe72e348529ebd8ee56f202872258ccd803cee472079222d68acfd70e9b" => :yosemite
  end

  option "without-gui", "Build without WxPython interface. Command line tools still available."

  depends_on UnlinkedGRASS6

  # TODO: test on 10.6 first. may work with latest wxWidgets 3.0
  # depends on :macos => :lion
  # TODO: builds with clang (has same non-fatal errors as gcc), but is it compiled correctly?
  # depends on "gcc" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  depends_on "gdal"
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on :python
  depends_on "wxpython"
  depends_on :postgresql => :optional
  depends_on :mysql => :optional
  depends_on "cairo"
  depends_on :x11 # needs to find at least X11/include/GL/gl.h

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
  end

  def install
    readline = Formula["readline"].opt_prefix
    gettext = Formula["gettext"].opt_prefix

    # noinspection RubyLiteralArrayInspection
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
      "--with-proj-share=#{Formula["proj"].opt_share}/proj",
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

    if MacOS.version >= :el_capitan
      # handle stripping of DYLD_* env vars by SIP when passed to utilities;
      # HOME env var is .brew_home during build, so it is still checked for lib
      ln_sf "#{buildpath}/dist.x86_64-apple-darwin#{`uname -r`.strip}/lib", ".brew_home/lib"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make", "GDAL_DYNAMIC=" # make and make install must be separate steps.
    system "make", "GDAL_DYNAMIC=", "install" # GDAL_DYNAMIC set to blank for r.external compatability
  end

  def post_install
    # ensure QGIS's Processing plugin recognizes install
    ln_sf "../bin/grass64", prefix/"grass-#{version}/grass.sh"
    # link so settings in external apps don't need updated on grass version bump
    # in QGIS Processing options, GRASS folder = HOMEBREW_PREFIX/opt/grass6/grass-base
    ln_sf "grass-#{version}", prefix/"grass-base"
  end

  def formula_site_packages(f)
    `python2 -c "import os, sys, site; sp1 = list(sys.path); site.addsitedir('#{Formula[f].opt_lib}/python2.7/site-packages'); print(os.pathsep.join([x for x in sys.path if x not in sp1]))"`.strip
  end

  def caveats
    if headless?
      <<-EOS.undent
        This build of GRASS has been compiled without the WxPython GUI.

        The command line tools remain fully functional.
        EOS
    end
  end

  test do
    system "#{bin}/grass64", "--version"
  end
end


__END__
diff --git a/Makefile b/Makefile
index 40b736d..1a1d8df 100644
--- a/Makefile
+++ b/Makefile
@@ -311,8 +311,6 @@ ifeq ($(strip $(MINGW)),)
 	-tar cBf - gem/skeleton | (cd ${INST_DIR}/etc ; tar xBf - ) 2>/dev/null
 	-${INSTALL} gem/gem$(GRASS_VERSION_MAJOR)$(GRASS_VERSION_MINOR) ${BINDIR} 2>/dev/null
 endif
-	@# enable OSX Help Viewer
-	@if [ "`cat include/Make/Platform.make | grep -i '^ARCH.*darwin'`" ] ; then /bin/ln -sfh "${INST_DIR}/docs/html" /Library/Documentation/Help/GRASS-${GRASS_VERSION_MAJOR}.${GRASS_VERSION_MINOR} ; fi
 
 
 install-strip: FORCE
diff --git a/raster/r.terraflow/direction.cpp b/raster/r.terraflow/direction.cpp
index 7744518..778c225 100644
--- a/raster/r.terraflow/direction.cpp
+++ b/raster/r.terraflow/direction.cpp
@@ -53,11 +53,11 @@ encodeDirectionMFD(const genericWindow<elevation_type>& elevwin,
   
   if(!is_nodata(elevwin.get())) {
     dir = 0;
-    if (elevwin.get(5) < elevwin.get() && !is_void(elevwin.get(5))) dir |= 1;
-    if (elevwin.get(3) < elevwin.get() && !is_void(elevwin.get(3))) dir |= 16;
+    if (elevwin.get(5) < elevwin.get() && !is_voided(elevwin.get(5))) dir |= 1;
+    if (elevwin.get(3) < elevwin.get() && !is_voided(elevwin.get(3))) dir |= 16;
     for(int i=0; i<3; i++) {
-      if(elevwin.get(i) < elevwin.get() && !is_void(elevwin.get(i))) dir |= 32<<i;
-      if(elevwin.get(i+6) < elevwin.get() && !is_void(elevwin.get(6+i))) dir |= 8>>i;
+      if(elevwin.get(i) < elevwin.get() && !is_voided(elevwin.get(i))) dir |= 32<<i;
+      if(elevwin.get(i+6) < elevwin.get() && !is_voided(elevwin.get(6+i))) dir |= 8>>i;
     }
   }
   
diff --git a/raster/r.terraflow/nodata.cpp b/raster/r.terraflow/nodata.cpp
index 159c66d..610ca55 100644
--- a/raster/r.terraflow/nodata.cpp
+++ b/raster/r.terraflow/nodata.cpp
@@ -73,7 +73,7 @@ is_nodata(float x) {
 
 
 int
-is_void(elevation_type el) {
+is_voided(elevation_type el) {
   return (el == nodataType::ELEVATION_NODATA);
 }
 
diff --git a/raster/r.terraflow/nodata.h b/raster/r.terraflow/nodata.h
index 1e843c5..ac56504 100644
--- a/raster/r.terraflow/nodata.h
+++ b/raster/r.terraflow/nodata.h
@@ -37,7 +37,7 @@
 int is_nodata(elevation_type el);
 int is_nodata(int x);
 int is_nodata(float x);
-int is_void(elevation_type el);
+int is_voided(elevation_type el);
 
 
 class nodataType : public ijBaseType {
