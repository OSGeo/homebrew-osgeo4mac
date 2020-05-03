class OsgeoLiblas < Formula
  desc "C/C++ library for reading and writing the LAS LiDAR format"
  homepage "https://liblas.org/"
   url "https://github.com/libLAS/libLAS/archive/bd157f25b3de9747fa3146f9dcf2323bc275b254.tar.gz"
   sha256 "9e056b8f973cdfc0e772290a16af8a2c895d997e25677332fe70ae60420913b5"
   version "1.8.1"
  #url "https://github.com/libLAS/libLAS.git",
  #  :branch => "master",
  #  :commit => "11a9435cc90ec40c4abbc498cbb1412dd8c33588"
  #version "1.8.1"

  revision 9

  # gt_wkt_srs_cpp
  patch :DATA

  head "https://github.com/libLAS/libLAS.git", :branch => "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 "5df647f195369ccdcfa3199344a772ba656f66195228b7ac2bba4a3a0a116faa" => :catalina
    sha256 "5df647f195369ccdcfa3199344a772ba656f66195228b7ac2bba4a3a0a116faa" => :mojave
    sha256 "5df647f195369ccdcfa3199344a772ba656f66195228b7ac2bba4a3a0a116faa" => :high_sierra
  end

  keg_only "other version built against older gdal is in main tap"

  option "with-test", "Verify during install with `make test`"
  option "with-laszip", "Build with laszip support"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "zlib"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "libxml2"
  depends_on "osgeo-libgeotiff"
  depends_on "osgeo-proj"
  depends_on "osgeo-gdal"
  depends_on "osgeo-laszip@2" if build.with? "laszip"
  # depends_on "pkgconfig"
  # other: oracle

  # for laszip 3.2.9
  # Failed to open /laszip/include/laszip/laszip.hpp file

  # is built from a more recent commit, the patches are already applied
  # See: https://github.com/libLAS/libLAS/issues/140

  # Fix ambiguous method error when building against GDAL 2.3
  # patch do
  #   url "https://github.com/nickrobison/libLAS/commit/ec10e274ee765aa54e7c71c8b44d2c7494e63804.patch?full_index=1"
  #   sha256 "3f8aefa1073aa32de01175cd217773020d93e5fb44a4592d76644a242bb89a3c"
  # end

  # Fix build for Xcode 9 with upstream commit
  # Remove in next version
  # patch do
  #   url "https://github.com/libLAS/libLAS/commit/49606470.patch?full_index=1"
  #   sha256 "5590aef61a58768160051997ae9753c2ae6fc5b7da8549707dfd9a682ce439c8"
  # end

  def install
    ENV.cxx11
    # ENV.append "CXXFLAGS", "-std=c++11"

    mkdir "macbuild" do
      # CMake finds boost, but variables like this were set in the last
      # version of this formula. Now using the variables listed here:
      #   https://liblas.org/compilation.html
      ENV["Boost_INCLUDE_DIR"] = "#{HOMEBREW_PREFIX}/include"
      ENV["Boost_LIBRARY_DIRS"] = "#{HOMEBREW_PREFIX}/lib"
      args = ["-DWITH_GEOTIFF=ON", "-DWITH_GDAL=ON"] + std_cmake_args

      if build.with? "laszip"
        args << "-DWITH_LASZIP=ON"
        args << "-DLASZIP_INCLUDE_DIR=#{Formula['osgeo-laszip@2'].opt_include}"
        args << "-DLASZIP_LIBRARY=#{Formula['osgeo-laszip@2'].opt_lib}/liblaszip.dylib"
        rgs << "-DWITH_STATIC_LASZIP=ON"
      end

      args << "-DPROJ4_INCLUDE_DIR=#{Formula['osgeo-proj'].opt_include}"
      args << "-DPROJ4_LIBRARY=#{Formula['osgeo-proj'].opt_lib}"

      # args << "-DWITH_PKGCONFIG=ON"

      args << "-DWITH_UTILITIES=ON"

      system "cmake", "..", *args
      system "make"
      system "make", "test" if build.with?("test") # || build.bottle?
      system "make", "install"

      # fix for liblas-config
      # for some reason it does not build
      # bin.install resource("liblas-config")
    end

    # Fix rpath value, to ensure grass7 grabs the correct dylib
    MachO::Tools.change_install_name("#{lib}/liblas_c.3.dylib", "@rpath/liblas.3.dylib", "#{opt_lib}/liblas.3.dylib")
  end

  def post_install
    # fix liblas-conf
    config = <<~EOS
      #!/bin/sh
      # prefix=#{prefix}
      # exec_prefix=#{bin}
      # libdir=#{lib}

      INCLUDES="-I#{prefix}/include "
      LIBS="-L#{lib} -llas -llas_c -L#{HOMEBREW_PREFIX}/lib #{HOMEBREW_PREFIX}/lib/libboost_program_options-mt.dylib #{HOMEBREW_PREFIX}/lib/libboost_thread-mt.dylib"

      GDAL_INCLUDE="#{Formula['osgeo-gdal'].opt_include}"
      if test -n "$GDAL_INCLUDE" ; then
          INCLUDES="$INCLUDES -I$GDAL_INCLUDE"
      fi
      GDAL_LIBRARY="#{Formula['osgeo-gdal'].opt_lib}/libgdal.dylib"
      if test -n "$GDAL_LIBRARY" ; then
          LIBS="$LIBS $GDAL_LIBRARY"
      fi

      GEOTIFF_INCLUDE="#{Formula['osgeo-libgeotiff'].opt_include}"
      if test -n "$GEOTIFF_INCLUDE" ; then
          INCLUDES="$INCLUDES -I$GEOTIFF_INCLUDE"
      fi
      GEOTIFF_LIBRARY="#{Formula['osgeo-libgeotiff'].opt_lib}/libgeotiff.dylib"
      if test -n "$GEOTIFF_LIBRARY" ; then
          LIBS="$LIBS $GEOTIFF_LIBRARY"
      fi

      ORACLE_INCLUDE=""
      if test -n "$ORACLE_INCLUDE" ; then
          INCLUDES="$INCLUDES -I$ORACLE_INCLUDE"
      fi
      ORACLE_OCI_LIBRARY=""
      if test -n "$ORACLE_OCI_LIBRARY" ; then
          LIBS="$LIBS $ORACLE_OCI_LIBRARY   "
      fi

      TIFF_INCLUDE="#{Formula['libtiff'].opt_include}"
      if test -n "$TIFF_INCLUDE" ; then
          INCLUDES="$INCLUDES -I$TIFF_INCLUDE"
      fi
      TIFF_LIBRARY="#{Formula['libtiff'].opt_lib}/libtiff.dylib"
      if test -n "$TIFF_LIBRARY" ; then
          LIBS="$LIBS $TIFF_LIBRARY"
      fi

      LIBXML2_INCLUDE_DIR="#{Formula['libxml2'].opt_include}"
      if test -n "$LIBXML2_INCLUDE_DIR" ; then
          INCLUDES="$INCLUDES -I$LIBXML2_INCLUDE_DIR"
      fi
      LIBXML2_LIBRARIES="#{Formula['libxml2'].opt_lib}/libxml2.dylib"
      if test -n "$LIBXML2_LIBRARIES" ; then
          LIBS="$LIBS $LIBXML2_LIBRARIES"
      fi

      LASZIP_INCLUDE_DIR="#{Formula['osgeo-laszip@2'].opt_include}"
      if test -n "$LASZIP_INCLUDE_DIR" ; then
          INCLUDES="$INCLUDES -I$LASZIP_INCLUDE_DIR"
      fi
      LASZIP_LIBRARY="#{Formula['osgeo-laszip@2'].opt_lib}/liblaszip.dylib"
      if test -n "$LASZIP_LIBRARY" ; then
          LIBS="$LIBS $LASZIP_LIBRARY"
      fi


      usage()
      {
        cat <<EOF
      Usage: liblas-config [OPTIONS]
      Options:
        [--libs]
        [--cflags]
        [--cxxflags]
        [--defines]
        [--includes]
        [--version]
      EOF
        exit $1
      }

      if test $# -eq 0; then
        usage 1 1>&2
      fi

      case $1 in
        --libs)
          echo $LIBS
          ;;

        --prefix)
          echo ${prefix}
           ;;

        --ldflags)
          echo -L${libdir}
          ;;

        --defines)
          echo  -DHAVE_GDAL=1 -DHAVE_LIBGEOTIFF=1
          ;;

        --includes)
          echo ${INCLUDES}
          ;;

        --cflags)
          echo ${INCLUDES}/liblas
          ;;

        --cxxflags)
          echo   -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wpointer-arith -Wcast-align -Wcast-qual -Wfloat-equal -Wredundant-decls -Wno-long-long
          ;;

        --version)
          echo 1.8.1
          ;;

        *)
          usage 1 1>&2
          ;;

      esac
    EOS

    (bin/"liblas-config").write config

    chmod("+x", "#{bin}/liblas-config")

    # fix liblas.pc
    rm "#{lib}/pkgconfig/liblas.pc"
    File.open("#{lib}/pkgconfig/liblas.pc", "w") { |file|
      file << "Name: libLAS\n"
      file << "Description: Library (C/C++) and tools for the LAS LiDAR format\n"
      file << "Requires: geotiff\n"
      file << "Version: #{version}\n"
      file << "Libs: -L#{lib} -llas -llas_c\n"
      file << "Cflags: -I#{include}/liblas"
    }
  end

  test do
    # for some reason it fails in CI, but this works
    # system bin/"liblas-config", "--version"
  end
end

__END__

--- /src/gt_wkt_srs.cpp
+++ /src/gt_wkt_srs.cpp
@@ -299,7 +299,7 @@
                 oSRS.SetFromUserInput(pszWKT);
                 oSRS.SetExtension( "PROJCS", "PROJ4",
                                    "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs" );
-                oSRS.FixupOrdering();
+                //oSRS.FixupOrdering();
                 CPLFree(pszWKT);
                 pszWKT = NULL;
                 oSRS.exportToWkt(&pszWKT);
@@ -505,7 +505,7 @@
         {
             char	*pszWKT;
             oSRS.morphFromESRI();
-            oSRS.FixupOrdering();
+            //oSRS.FixupOrdering();
             if( oSRS.exportToWkt( &pszWKT ) == OGRERR_NONE )
                 return pszWKT;
         }
@@ -1107,7 +1107,7 @@
 /* ==================================================================== */
     char	*pszWKT;

-    oSRS.FixupOrdering();
+    //oSRS.FixupOrdering();

     if( oSRS.exportToWkt( &pszWKT ) == OGRERR_NONE )
         return pszWKT;
