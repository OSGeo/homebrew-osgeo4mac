class Ossim < Formula
  desc "Geospatial libs and apps to process imagery, terrain, and vector data"
  homepage "https://trac.osgeo.org/ossim/"

  stable do
    url "https://github.com/ossimlabs/ossim/archive/Gasparilla-2.3.1.tar.gz"
    sha256 "f928544b4dfc6a1c93c55afb244d04e9a33b368fd5e6c3fe552f43b5da4e7c6e"
  end

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    sha256 "bada06e2e468f8398c623b24a581933bb22e5bfeb43a4867c7a71a861f133cd5" => :high_sierra
    sha256 "bada06e2e468f8398c623b24a581933bb22e5bfeb43a4867c7a71a861f133cd5" => :sierra
  end

  # This patch is required in order to build on XCode 8.3
  # It's been submitted upstream as: https://github.com/ossimlabs/ossim/pull/199
  patch :DATA

  option "with-curl-apps", "Build curl-dependent apps"
  option "without-framework", "Generate library instead of framework"
  option "with-gui", "Build new ossimGui library and geocell application"

  depends_on "cmake" => :build
  depends_on "open-scene-graph" # just for its OpenThreads lib
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libtiff"
  depends_on "libgeotiff"
  depends_on "geos"
  depends_on "freetype"
  depends_on "zlib"
  depends_on "open-mpi" => :optional

  def install
    ENV.cxx11

    ENV["OSSIM_DEV_HOME"] = buildpath.to_s
    ENV["OSSIM_BUILD_DIR"] = (buildpath/"build").to_s
    ENV["OSSIM_INSTALL_PREFIX"] = prefix.to_s

    # TODO: add options and deps for plugins
    args = std_cmake_args + %W[
      -DOSSIM_DEV_HOME=#{ENV["OSSIM_DEV_HOME"]}
      -DINSTALL_LIBRARY_DIR=lib
      -DBUILD_OSSIM_APPS=ON
      -DBUILD_OMS=OFF
      -DBUILD_CNES_PLUGIN=OFF
      -DBUILD_GEOPDF_PLUGIN=OFF
      -DBUILD_GDAL_PLUGIN=OFF
      -DBUILD_HDF5_PLUGIN=OFF
      -DBUILD_KAKADU_PLUGIN=OFF
      -DBUILD_KML_PLUGIN=OFF
      -DBUILD_MRSID_PLUGIN=OFF
      -DMRSID_DIR=
      -DOSSIM_PLUGIN_LINK_TYPE=SHARED
      -DBUILD_OPENCV_PLUGIN=OFF
      -DBUILD_OPENJPEG_PLUGIN=OFF
      -DBUILD_PDAL_PLUGIN=OFF
      -DBUILD_PNG_PLUGIN=OFF
      -DBUILD_POTRACE_PLUGIN=OFF
      -DBUILD_SQLITE_PLUGIN=OFF
      -DBUILD_WEB_PLUGIN=OFF
      -DBUILD_OSSIM_VIDEO=OFF
      -DBUILD_OSSIM_WMS=OFF
      -DBUILD_OSSIM_PLANET=OFF
      -DOSSIM_BUILD_ADDITIONAL_DIRECTORIES=
      -DBUILD_OSSIM_TESTS=OFF
    ]

    args << "-DBUILD_OSSIM_FRAMEWORKS=" + (build.with?("framework") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_MPI_SUPPORT=" + (build.with?("mpi") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_CURL_APPS=" + (build.with?("curl-apps") ? "ON" : "OFF")
    args << "-DBUILD_OSSIM_GUI=" + (build.with?("gui") ? "ON" : "OFF")

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system bin/"ossim-cli", "--version"
  end
end
__END__
diff --git a/include/ossim/base/ossimRefPtr.h b/include/ossim/base/ossimRefPtr.h
index fef5824..dbe015a 100644
--- a/include/ossim/base/ossimRefPtr.h
+++ b/include/ossim/base/ossimRefPtr.h
@@ -8,6 +8,7 @@
 #define ossimRefPtr_HEADER
 #include <ossim/base/ossimConstants.h>
 #include <stddef.h>
+#include <cstddef>
 
 template<class T> class ossimRefPtr
 {
@@ -100,20 +101,20 @@ template<typename _Tp1, typename _Tp2> inline bool
   operator==(const ossimRefPtr<_Tp1>& __a, const ossimRefPtr<_Tp2>& __b) noexcept
   { return __a.get() == __b.get(); }
 
-template<typename _Tp> inline bool operator==(const ossimRefPtr<_Tp>& __a, nullptr_t) noexcept
+template<typename _Tp> inline bool operator==(const ossimRefPtr<_Tp>& __a, std::nullptr_t) noexcept
   { return !__a; }
 
-template<typename _Tp> inline bool operator==(nullptr_t, const ossimRefPtr<_Tp>& __a) noexcept
+template<typename _Tp> inline bool operator==(std::nullptr_t, const ossimRefPtr<_Tp>& __a) noexcept
   { return !__a; }
 
 template<typename _Tp1, typename _Tp2>  inline bool
   operator!=(const ossimRefPtr<_Tp1>& __a, const ossimRefPtr<_Tp2>& __b) noexcept
   { return __a.get() != __b.get(); }
 
-template<typename _Tp> inline bool operator!=(const ossimRefPtr<_Tp>& __a, nullptr_t) noexcept
+template<typename _Tp> inline bool operator!=(const ossimRefPtr<_Tp>& __a, std::nullptr_t) noexcept
   { return (bool)__a; }
 
-template<typename _Tp> inline bool operator!=(nullptr_t, const ossimRefPtr<_Tp>& __a) noexcept
+template<typename _Tp> inline bool operator!=(std::nullptr_t, const ossimRefPtr<_Tp>& __a) noexcept
   { return (bool)__a; }
 
 
