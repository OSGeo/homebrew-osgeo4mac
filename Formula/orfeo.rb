require 'formula'

class Orfeo < Formula
  homepage 'http://www.orfeo-toolbox.org/otb/'
  url 'http://downloads.sourceforge.net/project/orfeo-toolbox/OTB/OTB-3.20/OTB-3.20.0.tgz'
  sha1 '2af5b4eb857d0f1ecb1fd1107c6879f9d79dd0fc'

  option "with-external-libs", "Build using some external Homebrew libs"

  depends_on 'cmake' => :build
  depends_on :python => :optional
  depends_on 'fltk'
  depends_on 'gdal'
  depends_on 'qt'
  if build.with? "external-libs"
    #depends_on "boost" # untested
    #depends_on "open-scene-graph" # (for libOpenThreads) build fails!
    depends_on "liblas"
    depends_on "libkml"
    depends_on "minizip"
    depends_on "muparser"
    depends_on "tinyxml"
  end
  depends_on "fftw" => :optional # restricts built binaries to GPL license
  # these are currently experimental
  depends_on "gettext" => :optional
  depends_on "libpqxx" => :optional
  depends_on "opencv" => :optional

  option 'examples', 'Compile and install various examples'
  option 'java', 'Enable Java support'
  option 'patented', 'Enable patented algorithms'

  resource "geoid" do
    # geoid file to use in elevation calculations, if no DEM defined
    url "http://hg.orfeo-toolbox.org/OTB-Data/raw-file/dec1ce83a5f3/Input/DEM/egm96.grd"
    sha1 "034ae375ff41b87d5e964f280fde0438c8fc8983"
    version "3.20.0"
  end

  def patches
    # Fix some CMake modules
    # Ensure external liblas_c and liblas are found on Mac
    # Ensure external libOpenThreads is not used unless specified; otherwise it
    # possibly uses open-scene-graph's lib, which doesn't link against orfeo
    DATA
  end

  def install
    (share/"orfeo/default_geoid").install resource("geoid")

    args = std_cmake_args + %W[
      -DBUILD_APPLICATIONS=ON
      -DOTB_USE_EXTERNAL_FLTK=ON
      -DBUILD_TESTING=OFF
      -DOTB_USE_EXTERNAL_OPENTHREADS=OFF
      -DBUILD_SHARED_LIBS=ON
      -DOTB_WRAP_QT=ON
    ]

    args << '-DBUILD_EXAMPLES=' + ((build.include? 'examples') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_JAVA=' + ((build.include? 'java') ? 'ON' : 'OFF')
    args << '-DOTB_USE_PATENTED=' + ((build.include? 'patented') ? 'ON' : 'OFF')
    args << '-DOTB_WRAP_PYTHON=OFF' if build.without? 'python'
    args << "-DUSE_FFTWF=" + ((build.with? "fftw") ? "ON" : "OFF")
    args << "-DOTB_USE_GETTEXT=" + ((build.with? "gettext") ? "ON" : "OFF")
    args << "-DOTB_USE_PQXX=" + ((build.with? "libpqxx") ? "ON" : "OFF")
    args << "-DOTB_USE_OPENCV=" + ((build.with? "opencv") ? "ON" : "OFF")

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make'
      system 'make install'
    end
  end
end

__END__
diff --git a/CMake/FindLibLAS.cmake b/CMake/FindLibLAS.cmake
index 4a1ba35..4b7fdc7 100644
--- a/CMake/FindLibLAS.cmake
+++ b/CMake/FindLibLAS.cmake
@@ -14,7 +14,7 @@ ENDIF( LIBLAS_INCLUDE_DIR )
 FIND_PATH( LIBLAS_INCLUDE_DIR liblas/capi/liblas.h )
 
 FIND_LIBRARY( LIBLAS_LIBRARY
-              NAMES liblas_c liblas )
+              NAMES liblas_c liblas las_c las )
 
 # handle the QUIETLY and REQUIRED arguments and set LIBLAS_FOUND to TRUE if
 # all listed variables are TRUE
diff --git a/CMake/ImportOpenThreads.cmake b/CMake/ImportOpenThreads.cmake
index 56c64b6..1aa4e75 100644
--- a/CMake/ImportOpenThreads.cmake
+++ b/CMake/ImportOpenThreads.cmake
@@ -7,7 +7,7 @@ MARK_AS_ADVANCED(OPENTHREADS_LIBRARY)
 MARK_AS_ADVANCED(OPENTHREADS_LIBRARY_DEBUG)
 
 SET(OTB_USE_EXTERNAL_OPENTHREADS ON CACHE INTERNAL "")
-IF(OPENTHREADS_FOUND)
+IF(OPENTHREADS_FOUND AND OTB_USE_EXTERNAL_OPENTHREADS)
 
         INCLUDE_DIRECTORIES(${OPENTHREADS_INCLUDE_DIR})
         LINK_DIRECTORIES( ${OPENTHREADS_LIBRARY} )
