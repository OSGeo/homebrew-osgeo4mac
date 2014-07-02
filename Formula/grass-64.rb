require "formula"

class Grass64 < Formula
  homepage "http://grass.osgeo.org/"

  stable do
    url "http://grass.osgeo.org/grass64/source/grass-6.4.4.tar.gz"
    sha1 "0e4dac9fb3320a26e4f640f641485fde0323dd46"

    # Patches to keep files from being installed outside of the prefix.
    # Remove lines from Makefile that try to install to /Library/Documentation.
    # Also, quick patch for compiling with clang (as yet, unreported issue)
    patch :DATA
  end

  keg_only "grass is in main tap and same-name bin utilities are installed"

  option "without-gui", "Build without WxPython interface. Command line tools still available."

  # TODO: test on 10.6 first. may work with latest wxWidgets 3.0
  # depends_on :macos => :lion
  # TODO: builds with clang (has same non-fatal errors as gcc), but is it compiled correctly?
  # depends_on "gcc" => :build
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
  depends_on :x11  # needs to find at least X11/include/GL/gl.h

  fails_with :clang do
    cause "Multiple build errors while compiling GRASS tools."
  end

  def headless?
    # The GRASS GUI is based on WxPython.
    build.without? "gui"
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
      ENV["PYTHONPATH"] = "#{Formula["wxpython"].opt_prefix}/lib/python2.7/site-packages"
      args << "--with-wxwidgets=#{Formula["wxmac"].opt_prefix}/bin/wx-config"
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
diff --git a/raster/r.terraflow/direction.cc b/raster/r.terraflow/direction.cc
index 7744518..778c225 100644
--- a/raster/r.terraflow/direction.cc
+++ b/raster/r.terraflow/direction.cc
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
   
diff --git a/raster/r.terraflow/nodata.cc b/raster/r.terraflow/nodata.cc
index 159c66d..610ca55 100644
--- a/raster/r.terraflow/nodata.cc
+++ b/raster/r.terraflow/nodata.cc
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
