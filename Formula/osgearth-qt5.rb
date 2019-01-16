class OsgearthQt5 < Formula
  desc "Geospatial SDK and terrain engine for OpenSceneGraph"
  homepage "http://osgearth.org"
  url "https://github.com/gwaldron/osgearth.git",
    :branch => "2.10",
    :commit => "62ddefab67334e41d1e9f402fd17e03508e84169"
  version "2.10"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "0784fecac54032d20b907ff013b6d7fa23faf083981ac9d26340d61e4fe45845" => :mojave
    sha256 "0784fecac54032d20b907ff013b6d7fa23faf083981ac9d26340d61e4fe45845" => :high_sierra
    sha256 "0784fecac54032d20b907ff013b6d7fa23faf083981ac9d26340d61e4fe45845" => :sierra
  end

  revision 1

  head "https://github.com/gwaldron/osgearth.git", :branch => "master"

  option "without-minizip", "Build without Google KMZ file access support"
  option "with-docs-examples", "Build and install html documentation and examples"
  option "with-v8", "Build with Google's V8 JavaScript engine support"
  option "with-rocksdb", "Build with Rocksdb an Embedded key-value store for fast storage"
  # option "with-tinyxml", "Use external libtinyxml, instead of internal"
  # option "with-duktape", "Build with Duktape an Embeddable Javascript engine"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "curl"
  depends_on "expat"
  depends_on "gdal2"
  depends_on "geos"
  depends_on "glslang"
  depends_on "leveldb"
  depends_on "libzip"
  depends_on :macos => :mavericks
  depends_on "openscenegraph-qt5"
  depends_on "osgqt"
  depends_on "poco"
  depends_on "protobuf"
  depends_on "python" # for sphinx
  depends_on "qt"
  depends_on "sqlite"
  depends_on :x11
  depends_on "minizip" => :recommended
  depends_on "rocksdb" => :optional
  depends_on "v8" => :optional
  # depends_on "duktape" => :optional
  # depends_on "triton-sdk" => :optional # Triton Ocean SDK

  resource "Sphinx" do
    url "https://files.pythonhosted.org/packages/4d/ed/4595274b5c9ce53a768cc0804ef65fd6282c956b93919a969e98d53894e4/Sphinx-1.8.3.tar.gz"
    sha256 "c4cb17ba44acffae3d3209646b6baec1e215cad3065e852c68cc569d4df1b9f8"
  end

  # fix error: unknown type name 'GLDEBUGPROC'
  # restore osgEarthQt: osgEarthQt5
  # https://github.com/gwaldron/osgearth/commit/c7f9d22b60bd1bb969b853b34b7f3955141e8b07
  # qgis3: libosgEarthQt5.dylib needed by PlugIns/qgis/libglobeplugin.dylib
  patch :DATA

  def install
    ENV.cxx11

    if (build.with? "docs-examples") && (!which("sphinx-build"))
      # temporarily vendor a local sphinx install
      sphinx_dir = prefix/"sphinx"
      sphinx_site = sphinx_dir/"lib/python#{py_ver}/site-packages"
      sphinx_site.mkpath
      ENV.prepend_create_path "PYTHONPATH", sphinx_site
      resource("Sphinx").stage { quiet_system "python#{py_ver}", "setup.py", "install", "--prefix=#{sphinx_dir}" }
      ENV.prepend_path "PATH", sphinx_dir/"bin"
    end

    args = std_cmake_args
    args << "-DOSGEARTH_QT_BUILD=ON"
    args << "-DOSGEARTH_QT_BUILD_LEGACY_WIDGETS=ON"
    args << "-DDYNAMIC_OSGEARTH=ON"
    args << "-DOSGQT_LIBRARY=#{Formula["osgqt"].opt_lib}/libosgQt5.dylib"
    args << "-DCMAKE_PREFIX_PATH=#{Formula["qt"].opt_lib}/cmake"

    args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"

    args << "-DGDAL_LIBRARY=#{Formula["gdal2"].opt_lib}/libgdal.dylib"
    args << "-DGDAL_INCLUDE_DIR=#{Formula["gdal2"].opt_include}"
    args << "-DGEOS_LIBRARY=#{Formula["geos"].opt_lib}/libgeos.dylib"
    args << "-DGEOS_INCLUDE_DIR=#{Formula["geos"].opt_include}"
    args << "-DLEVELDB_LIBRARY=#{Formula["leveldb"].opt_lib}/libleveldb.dylib"
    args << "-DLEVELDB_INCLUDE_DIR=#{Formula["leveldb"].opt_include}"
    args << "-DOSG_DIR=#{Formula["openscenegraph-qt5"].opt_prefix}"
    args << "-DOSG_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosg.dylib"
    args << "-DOSGUTIL_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgUtil.dylib"
    args << "-DOSGDB_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgDB.dylib"
    args << "-DOSGTEXT_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgText.dylib"
    args << "-DOSGTERRAIN_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgTerrain.dylib"
    args << "-DOSGFX_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgFX.dylib"
    args << "-DOSGSIM_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgSim.dylib"
    args << "-DOSGVIEWER_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgViewer.dylib"
    args << "-DOSGGA_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgGA.dylib"
    args << "-DOSGWIDGET_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgWidget.dylib"
    args << "-DOSGSHADOW_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgShadow.dylib"
    args << "-DOSGMANIPULATOR_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgManipulator.dylib"
    args << "-DOSGPARTICLE_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libosgParticle.dylib"
    args << "-DOPENTHREADS_LIBRARY=#{Formula["openscenegraph-qt5"].opt_lib}/libOpenThreads.dylib"
    args << "-DOSG_INCLUDE_DIR=#{Formula["openscenegraph-qt5"].opt_include}"
    args << "-DOSG_GEN_INCLUDE_DIR=#{Formula["openscenegraph-qt5"].opt_include}"
    args << "-DPOCO_FOUNDATION_LIBRARY=#{Formula["poco"].opt_lib}/libPocoFoundation.dylib"
    args << "-DPOCO_NET_LIBRARY=#{Formula["poco"].opt_lib}/libPocoNet.dylib"
    args << "-DPOCO_UTIL_LIBRARY=#{Formula["poco"].opt_lib}/libPocoUtil.dylib"
    args << "-DPOCO_INCLUDE_DIR=#{Formula["poco"].opt_include}"
    args << "-DSQLITE3_LIBRARY=#{Formula["sqlite"].opt_lib}/libsqlite3.dylib"
    args << "-DSQLITE3_INCLUDE_DIR=#{Formula["sqlite"].opt_include}"

    if build.with? "rocksdb"
      args << "-DWITH_STATIC_ROCKSDB=ON"
      args << "-DROCKSDB_LIBRARY=#{Formula["rocksdb"].opt_lib}/librocksdb.dylib"
      args << "-DROCKSDB_INCLUDE_DIR=#{Formula["rocksdb"].opt_include}"
    end

    # v8 and minizip options should have empty values if not defined '--with'
    if build.without? "v8"
      args << "-DV8_INCLUDE_DIR=''" << "-DV8_BASE_LIBRARY=''" << "-DV8_SNAPSHOT_LIBRARY=''"
      args << "-DV8_ICUI18N_LIBRARY=''" << "-DV8_ICUUC_LIBRARY=''"
    end

    # if build.with? "triton"
    #   args << "-DTRITON_LIBRARY=#{Formula["triton-sdk"].opt_lib}"
    #   args << "-DTRITON_INCLUDE_DIR=#{Formula["triton-sdk"].opt_include}"
    # end

    # if build.with? "duktape"
    #   args << "-DWITH_EXTERNAL_DUKTAPE=ON"
    #   args << "-DDUKTAPE_LIBRARY=#{Formula["duktape"].opt_lib}/libduktaped.dylib"
    #   args << "-DDUKTAPE_INCLUDE_DIR=#{Formula["duktape"].opt_include}"
    # end

    # Failure to build with external tinyxml
    # https://github.com/gwaldron/osgearth/issues/1002
    # if build.with? "tinyxml"
    #   args << "-DWITH_EXTERNAL_TINYXML=ON"
    #   args << "-DTINYXML_LIBRARY=#{Formula["tinyxml"].opt_lib}/libtinyxml.dylib"
    #   args << "-DTINYXML_INCLUDE_DIR=#{Formula["tinyxml"].opt_include}"
    # end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end

    if build.with? "docs-examples"
      cd "docs" do
        system "make", "html"
        doc.install "build/html" => "html"
      end
      doc.install "data"
      doc.install "tests" => "examples"
      rm_r prefix/"sphinx" if File.exist?(prefix/"sphinx")
    end
  end

  def caveats
    osg = Formula["openscenegraph-qt5"]
    osgver = (osg.linked_keg.exist?) ? osg.version : "#.#.# (version)"
    <<~EOS
    This formula installs Open Scene Graph plugins. To ensure access when using
    the osgEarth toolset, set the OSG_LIBRARY_PATH enviroment variable to:

      #{HOMEBREW_PREFIX}/lib/osgPlugins-#{osgver}

    EOS
  end

  test do
    system "#{bin}/osgearth_version"
  end

  private

  def py_ver
    `#{Formula["python"].opt_bin}/python3 -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end
end


__END__

--- /src/osgEarthSplat/LandUseTileSource.cpp
+++ /src/osgEarthSplat/LandUseTileSource.cpp
@@ -22,6 +22,8 @@
 #include <osgEarth/ImageUtils>
 #include <osgEarth/SimplexNoise>

+typedef void (APIENTRY *GLDEBUGPROC)(GLenum source,GLenum type,GLuint id,GLenum severity,GLsizei length,const GLchar *message,const GLvoid *userParam);
+
 using namespace osgEarth;
 using namespace osgEarth::Splat;


--- /src/osgEarthQt/ViewerWidget.cpp
+++ /src/osgEarthQt/ViewerWidget.cpp
@@ -28,6 +28,8 @@
 #include <osgViewer/Viewer>
 #include <osgViewer/ViewerEventHandlers>

+typedef void (APIENTRY *GLDEBUGPROC)(GLenum source,GLenum type,GLuint id,GLenum severity,GLsizei length,const GLchar *message,const void *userParam);
+#include <QOpenGLContext>
 #include <QtGui>
 #include <QtCore/QTimer>
 #include <QWidget>


--- a/src/applications/osgearth_package_qt/PackageQtMainWindow
+++ b/src/applications/osgearth_package_qt/PackageQtMainWindow
@@ -35,6 +35,8 @@

 #include <osgDB/FileNameUtils>

+typedef void (APIENTRY *GLDEBUGPROC)(GLenum source,GLenum type,GLuint id,GLenum severity,GLsizei length,const GLchar *message,const void *userParam);
+#include <QOpenGLContext>
 #include <QAction>
 #include <QDockWidget>
 #include <QtGui>


--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -186,6 +186,21 @@
     FIND_LIBRARY(MATH_LIBRARY m)
 ENDIF(UNIX AND NOT ANDROID)

+
+IF(OSGEARTH_QT_BUILD)
+	OPTION(OSGEARTH_QT_BUILD "Enable to use Qt (build Qt-dependent libraries, plugins and examples)" ON)
+	OPTION(OSGEARTH_QT_BUILD_LEGACY_WIDGETS "Build the legacy Qt widgets" ON)
+	FIND_PACKAGE(Qt5Core REQUIRED)
+	FIND_PACKAGE(Qt5Gui REQUIRED)
+	FIND_PACKAGE(Qt5OpenGL REQUIRED)
+	FIND_PACKAGE(Qt5OpenGLExtensions REQUIRED)
+	FIND_PACKAGE(Qt5Widgets REQUIRED)
+	FIND_PACKAGE(Qt5MacExtras REQUIRED)
+	IF ( Qt5Core_FOUND AND Qt5Widgets_FOUND AND Qt5Gui_FOUND AND Qt5OpenGL_FOUND AND Qt5OpenGLExtensions_FOUND )
+		SET(QT_INCLUDES ${Qt5Widgets_INCLUDE_DIRS} ${Qt5OpenGL_INCLUDE_DIRS} ${Qt5OpenGLExtensions_INCLUDE_DIRS})
+		MESSAGE(STATUS "Found Qt version: ${Qt5Core_VERSION_STRING}")
+	ENDIF ()
+ENDIF()

 # Platform specific definitions


--- a/CMakeModules/FindOSG.cmake
+++ b/CMakeModules/FindOSG.cmake
@@ -138,6 +138,19 @@
 FIND_OSG_LIBRARY( OPENTHREADS_LIBRARY OpenThreads )
 FIND_OSG_LIBRARY( OPENTHREADS_LIBRARY_DEBUG OpenThreadsd )

+IF(OPENSCENEGRAPH_VERSION VERSION_LESS "3.6.3")
+  FIND_OSG_LIBRARY( OSGQT_LIBRARY osgQt )
+  FIND_OSG_LIBRARY( OSGQT_LIBRARY_DEBUG osgQtd )
+ELSE(OPENSCENEGRAPH_VERSION VERSION_LESS "3.6.3")
+  IF(Qt5Widgets_FOUND)
+    FIND_OSG_LIBRARY( OSGQT_LIBRARY osgQt5 )
+    FIND_OSG_LIBRARY( OSGQT_LIBRARY_DEBUG osgQt5d )
+  ELSE(Qt5Widgets_FOUND)
+    FIND_OSG_LIBRARY( OSGQT_LIBRARY osgQt )
+    FIND_OSG_LIBRARY( OSGQT_LIBRARY_DEBUG osgQtd )
+  ENDIF(Qt5Widgets_FOUND)
+ENDIF(OPENSCENEGRAPH_VERSION VERSION_LESS "3.6.3")
+
 SET( OSG_FOUND "NO" )
 IF( OSG_LIBRARY AND OSG_INCLUDE_DIR )
     SET( OSG_FOUND "YES" )


--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -14,6 +14,7 @@


 FOREACH( lib
+         osgEarthQt
          osgEarthSplat
          osgEarthSilverLining
          osgEarthTriton )


--- a/src/applications/CMakeLists.txt
+++ b/src/applications/CMakeLists.txt
@@ -43,6 +43,9 @@
 ADD_SUBDIRECTORY(osgearth_atlas)
 ADD_SUBDIRECTORY(osgearth_conv)
 ADD_SUBDIRECTORY(osgearth_3pv)
+IF (Qt5Widgets_FOUND OR QT4_FOUND AND NOT ANDROID AND OSGEARTH_QT_BUILD AND OSGEARTH_QT_BUILD_LEGACY_WIDGETS)
+    ADD_SUBDIRECTORY(osgearth_package_qt)
+ENDIF()
 ADD_SUBDIRECTORY(osgearth_featureinfo)

 IF(BUILD_OSGEARTH_EXAMPLES)
@@ -94,6 +97,10 @@
     ADD_SUBDIRECTORY(osgearth_drawables)
     ADD_SUBDIRECTORY(osgearth_magnify)
     ADD_SUBDIRECTORY(osgearth_eci)
+    IF (Qt5Widgets_FOUND OR QT4_FOUND AND NOT ANDROID AND OSGEARTH_QT_BUILD)
+        ADD_SUBDIRECTORY(osgearth_qt_simple)
+        ADD_SUBDIRECTORY(osgearth_qt_windows)
+    ENDIF()
     ADD_SUBDIRECTORY(osgearth_windows)

     IF(SILVERLINING_FOUND)
