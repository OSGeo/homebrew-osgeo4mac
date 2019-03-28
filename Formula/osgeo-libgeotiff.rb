class Unlinked < Requirement
  fatal true

  satisfy(:build_env => false) { !core_libgeotiff_linked }

  def core_libgeotiff_linked
    Formula["libgeotiff"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    s += "Unlink with \e[32mbrew unlink libgeotiff\e[0m or remove with brew \e[32muninstall --ignore-dependencies libgeotiff\e[0m\n\n" if core_libgeotiff_linked
    s
  end
end

class OsgeoLibgeotiff < Formula
  desc "Library and tools for dealing with GeoTIFF"
  homepage "https://geotiff.osgeo.org/"
  url "https://github.com/OSGeo/libgeotiff/archive/1.4.3.tar.gz"
  sha256 "96fb426877a99ecb66a73c0b912f42995bc1275c1ae687bbaab9ad97c4e8bdf2"

  bottle do
    root_url "https://dl.bintray.com/homebrew-osgeo/osgeo-bottles"
    rebuild 1
    sha256 "35738f006f130d0ab18a7a44ad3a6d56ff49f9ebd9b3d3243fd07a79ebf00284" => :mojave
    sha256 "35738f006f130d0ab18a7a44ad3a6d56ff49f9ebd9b3d3243fd07a79ebf00284" => :high_sierra
    sha256 "3ff9ac6b9b6924ab958544741f8d037bdb01b55b166f02bf718b5b874fbbda55" => :sierra
  end

  revision 2

  head "https://github.com/OSGeo/libgeotiff.git", :branch => "master"

  # ACCEPT_USE_OF_DEPRECATED_PROJ_API_H
  patch :DATA

  # keg_only "libgeotiff is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "zlib"
  depends_on "libtiff"
  depends_on "osgeo-proj"

  def install
    cd "libgeotiff" do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}",
                            "--with-jpeg", "--with-zlib"
      system "make" # Separate steps or install fails
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "geotiffio.h"
      #include "xtiffio.h"
      #include <stdlib.h>
      #include <string.h>

      int main(int argc, char* argv[])
      {
        TIFF *tif = XTIFFOpen(argv[1], "w");
        GTIF *gtif = GTIFNew(tif);
        TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, (uint32) 10);
        GTIFKeySet(gtif, GeogInvFlatteningGeoKey, TYPE_DOUBLE, 1, (double)123.456);

        int i;
        char buffer[20L];

        memset(buffer,0,(size_t)20L);
        for (i=0;i<20L;i++){
          TIFFWriteScanline(tif, buffer, i, 0);
        }

        GTIFWriteKeys(gtif);
        GTIFFree(gtif);
        XTIFFClose(tif);
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lgeotiff",
                   "-L#{Formula["libtiff"].opt_lib}", "-ltiff", "-o", "test"
    system "./test", "test.tif"
    output = shell_output("#{bin}/listgeo test.tif")
    assert_match /GeogInvFlatteningGeoKey.*123.456/, output
  end
end

__END__

--- a/libgeotiff/geotiff_proj4.c
+++ b/libgeotiff/geotiff_proj4.c
@@ -1374,6 +1374,7 @@
 }
 #else

+#define ACCEPT_USE_OF_DEPRECATED_PROJ_API_H
 #include "proj_api.h"

 /************************************************************************/
