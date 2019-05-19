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
  url "https://github.com/openscenegraph/OpenSceneGraph/archive/OpenSceneGraph-3.6.3.tar.gz"
  sha256 "51bbc79aa73ca602cd1518e4e25bd71d41a10abd296e18093a8acfebd3c62696"

  revision 3

  head "https://github.com/openscenegraph/OpenSceneGraph.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    rebuild 1
    sha256 "f33aa96bede704f4bf4cd4a2d022347c3dab74ef8af50e6b5f4aae856dce1b51" => :mojave
    sha256 "f33aa96bede704f4bf4cd4a2d022347c3dab74ef8af50e6b5f4aae856dce1b51" => :high_sierra
    sha256 "5b0f08e87d73279c05bf37bb32f7f28a0f0d9caa9497e35cc05819e08c1adc61" => :sierra
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
  depends_on "jpeg"
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

  depends_on "asio"
  depends_on "ilmbase"
  depends_on "v8"
  depends_on "llvm"
  depends_on "gstreamer"

  depends_on :x11

  # patch necessary to ensure support for gtkglext-quartz
  # filed as an issue to the developers https://github.com/openscenegraph/osg/issues/34
  patch :DATA

  def install
    # Fix "fatal error: 'os/availability.h' file not found" on 10.11 and
    # "error: expected function body after function declarator" on 10.12
    if MacOS.version == :sierra || MacOS.version == :el_capitan
      ENV["SDKROOT"] = MacOS.sdk_path
    end

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
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_Asio=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_ZeroConf=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_OpenCascade=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_LIBLAS=1"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_cairo=ON" # not used by the project

    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_FFmpeg=ON"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_GDAL=ON"
    # args << "-DCMAKE_DISABLE_FIND_PACKAGE_TIFF=ON"

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
