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
  url "https://github.com/OSGeo/libgeotiff/releases/download/1.5.1/libgeotiff-1.5.1.tar.gz"
  sha256 "f9e99733c170d11052f562bcd2c7cb4de53ed405f7acdde4f16195cd3ead612c"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 2
    sha256 "aa85c9ce4cf3066e711fffef60d9b0d4b7d695f23db2bd0b3a944f9d13fc302e" => :mojave
    sha256 "aa85c9ce4cf3066e711fffef60d9b0d4b7d695f23db2bd0b3a944f9d13fc302e" => :high_sierra
    sha256 "0df43a0519ffdb05ca3418b4b1c43969979c557fed49fbcd4860003e63a2b8e6" => :sierra
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
    # cd "libgeotiff" do
      # system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}",
                            "--with-jpeg", "--with-zlib"
      system "make" # Separate steps or install fails
      system "make", "install"
    # end
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
