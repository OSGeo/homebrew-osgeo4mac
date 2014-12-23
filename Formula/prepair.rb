class Prepair < Formula
  homepage "https://github.com/tudelft-gist/prepair"
  url "https://github.com/tudelft-gist/prepair.git", :revision => "f851a14faf402536c022f1f7e136cdb05a7b9e5d"
  version "0.0-f851a14"
  sha1 "f851a14faf402536c022f1f7e136cdb05a7b9e5d"

  depends_on "cmake" => :build
  depends_on "cgal"
  depends_on "gdal"

  # Instead of lib or commandline exe, build both
  patch :DATA

  def install
    libexec.install(%W[data icon.png]) # geojson sample data and project icon

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "install"
    end
  end

  test do
    mktemp do
      system "#{bin}/prepair", "--shpOut", "--ogr", "#{libexec}/data/CLC2006_180927.geojson"
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 730e8d6..1abadbf 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -66,13 +66,15 @@ include_directories( ${GDAL_INCLUDE_DIR} )
 # Creating entries for target: prepair
 # ############################
 
-if ( AS_LIBRARY )
-  add_library( prepair SHARED TriangleInfo.cpp PolygonRepair.cpp )
-else()
-  add_executable( prepair  TriangleInfo.cpp PolygonRepair.cpp prepair.cpp )
-endif()
-
+add_library( prepair SHARED TriangleInfo.cpp PolygonRepair.cpp )
+# Link to CGAL and third-party libraries
+target_link_libraries(prepair ${CGAL_LIBRARIES} ${CGAL_3RD_PARTY_LIBRARIES} ${GDAL_LIBRARY})
 add_to_cached_list( CGAL_EXECUTABLE_TARGETS prepair )
 
-# Link to CGAL and third-party libraries
-target_link_libraries(prepair   ${CGAL_LIBRARIES} ${CGAL_3RD_PARTY_LIBRARIES} ${GDAL_LIBRARY})
\ No newline at end of file
+add_executable( prepair-bin prepair.cpp )
+set_target_properties(prepair-bin PROPERTIES OUTPUT_NAME prepair)
+
+add_to_cached_list( CGAL_EXECUTABLE_TARGETS prepair-bin )
+target_link_libraries(prepair-bin prepair)
+
+install(TARGETS prepair-bin prepair RUNTIME DESTINATION bin LIBRARY DESTINATION lib)
