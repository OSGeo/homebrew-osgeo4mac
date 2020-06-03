class OsgeoHexer < Formula
  desc "LAS and OGR hexagonal density and boundary surface generation"
  homepage "https://github.com/hobu/hexer"
  url "https://github.com/hobu/hexer/archive/1.4.0.tar.gz"
  sha256 "886134fcdd75da2c50aa48624de19f5ae09231d5290812ec05f09f50319242cb"

  revision 5

  head "https://github.com/hobu/hexer.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "949ebcb075de3dca10041016a155d53cc130e797b985c4c9a84e3ba817727762" => :catalina
    sha256 "949ebcb075de3dca10041016a155d53cc130e797b985c4c9a84e3ba817727762" => :mojave
    sha256 "949ebcb075de3dca10041016a155d53cc130e797b985c4c9a84e3ba817727762" => :high_sierra
  end

  # Add cmath and limits headers to utils
  # Link with dl for curse on non-win32
  patch :DATA

  option "with-drawing", "Build Cairo-based SVG drawing"

  depends_on "cmake" => :build
  depends_on "osgeo-gdal" => :recommended

  depends_on "cairo" # if build.with? "drawing"

  def install
    args = std_cmake_args
    args << "-DWITH_DRAWING=TRUE" # if build.with? "drawing"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    # TODO
    # system "curse", "--version"
  end
end

__END__

--- a/include/hexer/Utils.hpp
+++ b/include/hexer/Utils.hpp
@@ -15,6 +15,9 @@

 #pragma once

+#include <cmath>
+#include <limits>
+
 namespace hexer
 {


From e06d361eec613ed046592d378a01bf0a0694a6f8 Mon Sep 17 00:00:00 2001
From: Pete Gadomski <pete.gadomski@gmail.com>
Date: Tue, 25 Apr 2017 16:08:24 +0000
Subject: [PATCH 2/2] Link with dl for curse on non-win32

---
 apps/CMakeLists.txt | 3 +++
 1 file changed, 3 insertions(+)

--- a/apps/CMakeLists.txt
+++ b/apps/CMakeLists.txt
@@ -17,6 +17,9 @@ endif()
 if(CURSE)
     add_executable(${CURSE} curse.cpp lasfile.hpp las.hpp las.cpp OGR.hpp OGR.cpp mmaplib.hpp pdal_util_export.hpp ProgramArgs.hpp Utils.cpp Utils.hpp )
     target_link_libraries(${CURSE} ${HEXER_LIB_NAME} ${HEXERBOOST_LIB_NAME})
+    if(NOT WIN32)
+        target_link_libraries(${CURSE} dl)
+    endif()
 endif()

 install(TARGETS ${HEXER_UTILITIES}
