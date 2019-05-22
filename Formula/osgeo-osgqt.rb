class OsgeoOsgqt < Formula
  desc "3D graphics toolkit (osgQt)"
  homepage "https://github.com/openscenegraph/osgQt"
  url "https://github.com/openscenegraph/osgQt.git",
    :branch => "master",
    :commit => "8c6db61ef8ab650b972556142cceb11db057bda9"
  version "3.6.3"

  revision 2

  head "https://github.com/openscenegraph/osgQt.git"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "6a35302754dd73e74eb3d94d9d8569c4f3c027350669ff6010acf1091651381e" => :mojave
    sha256 "6a35302754dd73e74eb3d94d9d8569c4f3c027350669ff6010acf1091651381e" => :high_sierra
    sha256 "ea0310e01f112a7ed1376164eee194dd94a420442aa332daef448bb535ac8c80" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "osgeo-openscenegraph"
  depends_on "qt"

  # compatible with the new and old versions of OSG
  # QtWindowingSystem exist from OSG 3.5.3
  # patch :DATA
  # for commit: 6d324db8a56feb7d1976e9fb3f1de9bf7d255646

  def install
    # Fix "fatal error: 'os/availability.h' file not found" on 10.11 and
    # "error: expected function body after function declarator" on 10.12
    if MacOS.version == :sierra || MacOS.version == :el_capitan
      ENV["SDKROOT"] = MacOS.sdk_path
    end

    args = std_cmake_args

    args << "-DCMAKE_PREFIX_PATH=#{Formula["qt"].opt_lib}/cmake"
    args << "-DCMAKE_CXX_FLAGS=-Wno-error=narrowing" # or: -Wno-c++11-narrowing
    args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
    args << "-DOSG_DEFAULT_IMAGE_PLUGIN_FOR_OSX=imageio"
    args << "-DOSG_WINDOWING_SYSTEM=Cocoa"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
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
    system ENV.cxx, "test.cpp", "-I#{include}", "-L#{lib}", "-I#{Formula["osgeo-openscenegraph"].opt_include}", "-L#{Formula["osgeo-openscenegraph"].opt_lib}", "-losg", "-o", "test"
    assert_equal `./test`.chomp, version.to_s
  end
end

__END__

--- /CMakeLists.txt
+++ /CMakeLists.txt
@@ -127,7 +127,7 @@

 PROJECT(osgQt)

-FIND_PACKAGE(OpenSceneGraph 3.0.0 REQUIRED osgDB osgGA osgUtil osgText osgViewer osgWidget)
+FIND_PACKAGE(OpenSceneGraph 3.6.3 REQUIRED osgDB osgGA osgUtil osgText osgViewer osgWidget)
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
