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
  url "https://github.com/OSGeo/libgeotiff/archive/1.5.1.tar.gz"
  sha256 "fb04491572afb25ffe60239fdfdcfa2c64e6cf644cad9b0b922b10115ccbd488"

  bottle do
    root_url "https://bottle.download.osgeo.org/"
    sha256 "3a8f017587d8481283cafd18104c54a29ec9cbb8cebf4070d49c3c0c2839f8f5" => :mojave
    sha256 "3a8f017587d8481283cafd18104c54a29ec9cbb8cebf4070d49c3c0c2839f8f5" => :high_sierra
    sha256 "ee627c5a30d9f85b122cdee2518d6b27fbe6edc403c4f65aa3a58af65188b03d" => :sierra
  end

  # revision 1

  head "https://github.com/OSGeo/libgeotiff.git", :branch => "master"

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
