class Test < Formula
  desc "Terrain Analysis Using Digital Elevation Models for hydrology"
  homepage "http://hydrology.usu.edu/taudem/taudem5/"
  url "https://github.com/dtarb/TauDEM/archive/v5.3.7.tar.gz"
  sha256 "12a3cc1f43bd4ba9fd518ed82e524e386c1eb28891dfd3ed4329e8ad0a390245"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    cellar :any
    rebuild 1
    sha256 "39b5e713f42d0334feeb574ace86e112c489ca0502790b365c14359dff3cb8f8" => :mojave
    sha256 "39b5e713f42d0334feeb574ace86e112c489ca0502790b365c14359dff3cb8f8" => :high_sierra
    sha256 "39b5e713f42d0334feeb574ace86e112c489ca0502790b365c14359dff3cb8f8" => :sierra
  end

  devel do
    url "https://github.com/dtarb/TauDEM/archive/v5.3.8.tar.gz"
    sha256 "30aee134f5eed2fb65825dd4e9e5181ed4ea6ae22c37d56ae5cfe2bdb9dab385"
  end

  head "https://github.com/dtarb/TauDEM.git", :branch => "master"

  # This patch is required to resolve some spacing errors in the CMake config
  # As reported by: https://github.com/ssolo/ALE/commit/2832cf63a6d822af5957417670b729c6a1301e80
  # and https://github.com/OSGeo/homebrew-osgeo4mac/issues/216
  patch :DATA

  depends_on "cmake" => :build
  depends_on "open-mpi"
  depends_on "gdal2"

  resource "logan" do
    url "http://hydrology.usu.edu/taudem/taudem5/LoganDemo.zip"
    sha256 "3340f75a30d3043e7ad09b7a7324fa71374811b22fa913ad577840499a7dab83"
    version "5.3.5"
  end

  def install
    ENV.cxx11
    args = std_cmake_args
    cd "src" do
      system "cmake", ".", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    resource("logan").stage do
      system "#{opt_prefix}/bin/pitremove", "logan.tif"
    end
  end
end

__END__
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 475133f..d249134 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -51,8 +51,8 @@ set (SINMAPSI SinmapSImn.cpp SinmapSI.cpp ${common_srcs})
 # MPI is required
 find_package(MPI REQUIRED)
 include_directories(${MPI_INCLUDE_PATH})
-set(CMAKE_CXX_FLAG ${CMAKE_CXX_FLAG} ${MPI_COMPILE_FLAGS})
-set(CMAKE_CXX_LINK_FLAGS ${CMAKE_CXX_LINK_FLAGS} ${MPI_LINK_FLAGS})
+set(CMAKE_CXX_FLAG "${CMAKE_CXX_FLAG} ${MPI_COMPILE_FLAGS}")
+set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} ${MPI_LINK_FLAGS}")

 # GDAL is required
 find_package(GDAL REQUIRED)
diff --git a/src/dinf.cpp b/src/dinf.cpp
index d1a7427..0820e91 100644
--- a/src/dinf.cpp
+++ b/src/dinf.cpp
@@ -568,7 +568,7 @@ long setPosDirDinf(tdpartition *elevDEM, tdpartition *flowDir, tdpartition *slop
 					elevDEM->getdxdyc(j,tempdxc,tempdyc);


-					float DXX[3] = {0,tempdxc,tempdyc};//tardemlib.cpp ln 1291
+					float DXX[3] = {0,static_cast<float>(tempdxc),static_cast<float>(tempdyc)};//tardemlib.cpp ln 1291
 					float DD = sqrt(tempdxc*tempdxc+tempdyc*tempdyc);//tardemlib.cpp ln 1293
 					SET2(j,i,DXX,DD, elevDEM,flowDir,slope);//i=y in function form old code j is x switched on purpose
 					//  Use SET2 from serial code here modified to get what it has as felevg.d from elevDEM partition
@@ -799,7 +799,7 @@ long resolveflats( tdpartition *elevDEM, tdpartition *flowDir, queue<node> *que,
 				//  direction based on the artificial elevations

 	elevDEM->getdxdyc(j,tempdxc,tempdyc);
-	float DXX[3] = {0,tempdxc,tempdyc};//tardemlib.cpp ln 1291
+	float DXX[3] = {0,static_cast<float>(tempdxc),static_cast<float>(tempdyc)};//tardemlib.cpp ln 1291
 	float DD = sqrt(tempdxc*tempdxc+tempdyc*tempdyc);//tardemlib.cpp ln 1293

 			SET2(j,i,DXX,DD,elevDEM,elev2,flowDir,dn);	//use new elevations to calculate flowDir.
