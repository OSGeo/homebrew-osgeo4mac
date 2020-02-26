class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !osgeo_openscenegraph_linked && !core_openscenegraph_linked }

  def osgeo_openscenegraph_linked
    Formula["osgeo-openscenegraph@3.4"].linked_keg.exist?
  rescue
    return false
  end

  def core_openscenegraph_linked
    Formula["open-scene-graph"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink osgeo-openscenegraph@3.4\e[0m or remove with \e[32mbrew uninstall --ignore-dependencies osgeo-openscenegraph@3.4\e[0m\n\n" if osgeo_openscenegraph_linked
    s += "Unlink with \e[32mbrew unlink open-scene-graph\e[0m or remove with brew \e[32muninstall --ignore-dependencies open-scene-graph\e[0m\n\n" if core_openscenegraph_linked
    s
  end
end

class OsgeoOpenscenegraph < Formula
  desc "High performance 3D graphics toolkit"
  homepage "http://www.openscenegraph.org/"
  url "https://github.com/openscenegraph/OpenSceneGraph/archive/OpenSceneGraph-3.6.5.tar.gz"
  sha256 "aea196550f02974d6d09291c5d83b51ca6a03b3767e234a8c0e21322927d1e12"

  revision 1

  head "https://github.com/openscenegraph/OpenSceneGraph.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "dc93f928689f846af65943a1a62b1381528c9429e05f8a43489a589aceddfd3f" => :catalina
    sha256 "dc93f928689f846af65943a1a62b1381528c9429e05f8a43489a589aceddfd3f" => :mojave
    sha256 "dc93f928689f846af65943a1a62b1381528c9429e05f8a43489a589aceddfd3f" => :high_sierra
  end

  # keg_only
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "curl"
  depends_on "dcmtk"
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "giflib"
  depends_on "gnuplot"
  depends_on "gtkglext"
  depends_on "jasper"
  # depends_on "jpeg"
  depends_on "jpeg-turbo"
  depends_on "librsvg"
  depends_on "libtiff"
  depends_on "mesa"
  depends_on "openexr"
  depends_on "perl"
  depends_on "poppler"
  depends_on "pth"
  depends_on "qt"
  depends_on "sdl"
  depends_on "wget"
  depends_on "zlib"
  depends_on "libxml2"
  depends_on "cairo"
  depends_on "gtk+"

  depends_on "osgeo-gdal"
  depends_on "osgeo-opencollada"

  depends_on "ilmbase"
  depends_on "v8"
  depends_on "llvm"
  depends_on "gstreamer"

  depends_on :x11

  # https://gentoobrowse.randomdan.homeip.net/packages/dev-games/openscenegraph
  # https://bugs.gentoo.org/698866
  # depends_on "asio"

  # patch necessary to ensure support for gtkglext-quartz
  # filed as an issue to the developers https://github.com/openscenegraph/osg/issues/34
  patch :DATA

  def install
    # Fix "fatal error: 'os/availability.h' file not found" on 10.11 and
    # "error: expected function body after function declarator" on 10.12
    if MacOS.version == :sierra || MacOS.version == :el_capitan
      ENV["SDKROOT"] = MacOS.sdk_path
    end

    ENV.cxx11
    ENV.append "CXXFLAGS", "-std=c++11"

    args = std_cmake_args

    args << "-DCMAKE_PREFIX_PATH=#{Formula["qt"].opt_lib}/cmake"
    args << "-DCMAKE_CXX_FLAGS=-Wno-error=narrowing"
    args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    args << "-DEGL_LIBRARY=#{Formula["mesa"].opt_lib}"
    args << "-DEGL_INCLUDE_DIR=#{Formula["mesa"].opt_include}/GLES/egl.h"

    # http://www.openscenegraph.org/index.php/community/maintainers-corner/packaging-openscenegraph
    args << "-DBUILD_DOCUMENTATION=ON"

    # disable unwanted optional dependencies to avoid opportunistic configuration
    # TODO: add some of these back either directly or as variants after testing
    args << "-DCMAKE_DISABLE_FIND_PACKAGE_GTA=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_Inventor=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_COLLADA=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_FBX=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_OpenVRML=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_LibVNCServer=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_SDL2=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_SDL=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_GtkGl=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_DirectInput=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_NVTT=1"
    args << "-DCMAKE_DISABLE_FIND_PACKAGE_Asio=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_ZeroConf=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_OpenCascade=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_LIBLAS=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_cairo=ON" # not used by the project

    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_FFmpeg=ON"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_GDAL=ON"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_TIFF=ON"

    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_Jasper=ON"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_OpenEXR=ON"

    args << "-DOSG_DEFAULT_IMAGE_PLUGIN_FOR_OSX=imageio"
    args << "-DOSG_WINDOWING_SYSTEM=Cocoa"
    args << "-DOSG_CONFIG_HAS_BEEN_RUN_BEFORE=YES"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "doc_openscenegraph"
      system "make", "install"
      doc.install Dir["#{prefix}/doc/OpenSceneGraphReferenceDocs/*"]
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <osg/Version>
      using namespace std;
      int main()
        {
          cout << osgGetVersion() << endl;
          return 0;
        }
    EOS
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-losg", "-o", "test"
    assert_equal `./test`.chomp, version.to_s
  end
end

__END__

--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1021,7 +1021,7 @@
         #C4706 assignment within conditional expression
         #C4589: Constructor of abstract class 'osgGA::CameraManipulator' ignores initializer for virtual base class 'osg::Object'
         SET(OSG_AGGRESSIVE_WARNING_FLAGS /W4 /wd4589 /wd4706 /wd4127 /wd4100)
-ELSEIF(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
+ELSEIF(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
         SET(OSG_AGGRESSIVE_WARNING_FLAGS  -Wall -Wparentheses -Wno-long-long -Wno-import -pedantic -Wreturn-type -Wmissing-braces -Wunknown-pragmas -Wunused -Wno-overloaded-virtual)

         # CMake lacks an elseif, so other non-gcc, non-VS compilers need
@@ -1032,25 +1032,17 @@
             SET(OSG_CXX_LANGUAGE_STANDARD "C++11" CACHE STRING "set the c++ language standard (C++98 / GNU++98 / C++11) for OSG" )
             MARK_AS_ADVANCED(OSG_CXX_LANGUAGE_STANDARD)
             # remove existing flags
-            REMOVE_CXX_FLAG(-std=c++98)
-            REMOVE_CXX_FLAG(-std=gnu++98)
-            REMOVE_CXX_FLAG(-std=c++11)
-            REMOVE_CXX_FLAG(-stdlib=libstdc++)
-            REMOVE_CXX_FLAG(-stdlib=libc++)

             IF(${OSG_CXX_LANGUAGE_STANDARD} STREQUAL "c++98" OR ${OSG_CXX_LANGUAGE_STANDARD} STREQUAL "C++98")
                 set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++98")
-                set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libstdc++")
-                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -stdlib=libstdc++")
+                set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98")
             ELSE()
                 IF(${OSG_CXX_LANGUAGE_STANDARD} STREQUAL "gnu++98" OR ${OSG_CXX_LANGUAGE_STANDARD} STREQUAL "GNU++98")
                     set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "gnu++98")
-                    set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libstdc++")
-                    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++98 -stdlib=libstdc++")
+                    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++98")
                 ELSE()
                     set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
-                    set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
-                    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
+                    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
                 ENDIF()
             ENDIF()

--- a/CMakeModules/FindGtkGl.cmake
+++ b/CMakeModules/FindGtkGl.cmake
@@ -10,7 +10,7 @@ IF(PKG_CONFIG_FOUND)
     IF(WIN32)
         PKG_CHECK_MODULES(GTKGL gtkglext-win32-1.0)
     ELSE()
-        PKG_CHECK_MODULES(GTKGL gtkglext-x11-1.0)
+        PKG_CHECK_MODULES(GTKGL gtkglext-quartz-1.0)
     ENDIF()

 ENDIF()
