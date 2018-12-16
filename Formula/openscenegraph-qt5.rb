class OpenscenegraphQt5 < Formula
  desc "High performance 3D graphics toolkit"
  homepage "http://www.openscenegraph.org/"
  url "https://github.com/openscenegraph/OpenSceneGraph.git",
  :branch => "OpenSceneGraph-3.6",
  :commit => "ea1e832d4d19eff5304c4e7d8da9e96ffa66bd12"
  version "3.6.3"

  # revision 1

  head "https://github.com/openscenegraph/OpenSceneGraph.git", :branch => "master"

  # patch necessary to ensure support for gtkglext-quartz
  # filed as an issue to the developers https://github.com/openscenegraph/osg/issues/34
  patch :DATA

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "graphviz" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "gtkglext"
  depends_on "jpeg"
  depends_on "sdl"
  depends_on "qt"
  depends_on "giflib"
  depends_on "jasper"
  depends_on "librsvg"
  depends_on "curl"
  depends_on "pth"
  depends_on "boost"
  depends_on "libtiff"
  depends_on "openexr"
  depends_on "zlib"
  depends_on "gdal2"
  depends_on "ffmpeg"
  depends_on "poppler"
  depends_on "dcmtk"
  depends_on "gnuplot"
  depends_on "perl"
  depends_on "wget"
  depends_on "mesa"
  # depends_on "gst-plugins-base"

  depends_on "asio" => :optional
  depends_on "opencollada" => :optional
  depends_on "ilmbase" => :optional
  depends_on "v8" => :optional
  # depends_on "libvncserver" => :optional # x11vnc
  # depends_on "fltk" => :optional

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
