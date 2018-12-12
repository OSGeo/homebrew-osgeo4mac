class Osgqt < Formula
  desc "3D graphics toolkit (osgQt)"
  homepage "https://github.com/openscenegraph/osgQt"
  url "https://github.com/openscenegraph/osgQt.git",
    :branch => "master",
    :commit => "6d324db8a56feb7d1976e9fb3f1de9bf7d255646"
  version "3.6.3"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    sha256 "a1abb537674638c66c7b9fbc5008ff8ee2fccdef8f9860f5b3a9c9f46c780ec5" => :mojave
    sha256 "a1abb537674638c66c7b9fbc5008ff8ee2fccdef8f9860f5b3a9c9f46c780ec5" => :high_sierra
    sha256 "a1abb537674638c66c7b9fbc5008ff8ee2fccdef8f9860f5b3a9c9f46c780ec5" => :sierra
  end

  # revision 1

  head "https://github.com/openscenegraph/osgQt.git"

  option "with-docs", "Build the documentation with Doxygen and Graphviz"

  deprecated_option "docs" => "with-docs"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "freetype"
  depends_on "sdl"
  depends_on "gdal2" => :optional
  depends_on "jasper" => :optional
  depends_on "openexr" => :optional
  depends_on "dcmtk" => :optional
  depends_on "librsvg" => :optional
  depends_on "collada-dom" => :optional
  depends_on "gnuplot" => :optional
  depends_on "ffmpeg" => :optional
  depends_on "qt"
  depends_on "open-scene-graph"

  # compatible with the new and old versions of OSG
  patch :DATA

  if build.with? "docs"
    depends_on "doxygen" => :build
    depends_on "graphviz" => :build
  end

  def install
    # Fix "fatal error: 'os/availability.h' file not found" on 10.11 and
    # "error: expected function body after function declarator" on 10.12
    if MacOS.version == :sierra || MacOS.version == :el_capitan
      ENV["SDKROOT"] = MacOS.sdk_path
    end

    args = std_cmake_args

    args << "-DBUILD_DOCUMENTATION=" + (build.with?("docs") ? "ON" : "OFF")
    args << "-DCMAKE_CXX_FLAGS=-Wno-error=narrowing" # or: -Wno-c++11-narrowing

    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
      args << "-DOSG_DEFAULT_IMAGE_PLUGIN_FOR_OSX=imageio"
      args << "-DOSG_WINDOWING_SYSTEM=Cocoa"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_32_bit}"
    end

    if build.with? "collada-dom"
      args << "-DCOLLADA_INCLUDE_DIR=#{Formula["collada-dom"].opt_include}/collada-dom2.4"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "doc_openscenegraph" if build.with? "docs"
      system "make", "install"
      doc.install Dir["#{prefix}/doc/OpenSceneGraphReferenceDocs/*"] if build.with? "docs"
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

--- /CMakeLists.txt
+++ /CMakeLists.txt
@@ -127,7 +127,7 @@

 PROJECT(osgQt)

-FIND_PACKAGE(OpenSceneGraph 3.0.0 REQUIRED osgDB osgGA osgUtil osgText osgViewer osgWidget)
+FIND_PACKAGE(OpenSceneGraph 3.6.2 REQUIRED osgDB osgGA osgUtil osgText osgViewer osgWidget)
 SET(OPENSCENEGRAPH_SOVERSION 145)

 SET(OSG_PLUGINS osgPlugins-${OPENSCENEGRAPH_VERSION})


--- /include/osgQt/GraphicsWindowQt
+++ /include/osgQt/GraphicsWindowQt
@@ -37,7 +37,7 @@
 // forward declarations
 class GraphicsWindowQt;

-#if OSG_VERSION_LESS_THAN(3, 5, 6)
+#if OSG_VERSION_LESS_THAN(3, 6, 3)
 /// The function sets the WindowingSystem to Qt.
 void OSGQT_EXPORT initQtWindowingSystem();
 #endif


--- /src/osgQt/GraphicsWindowQt.cpp
+++ /src/osgQt/GraphicsWindowQt.cpp
@@ -945,7 +945,7 @@
     QtWindowingSystem& operator=( const QtWindowingSystem& );
 };

-#if OSG_VERSION_GREATER_OR_EQUAL(3, 5, 6)
+#if OSG_VERSION_GREATER_OR_EQUAL(3, 6, 3)
 REGISTER_WINDOWINGSYSTEMINTERFACE(Qt, QtWindowingSystem)
 #else
