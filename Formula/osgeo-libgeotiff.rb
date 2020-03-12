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
  # url "https://github.com/OSGeo/libgeotiff/releases/download/1.5.1/libgeotiff-1.5.1.tar.gz"
  # sha256 "f9e99733c170d11052f562bcd2c7cb4de53ed405f7acdde4f16195cd3ead612c"
  url "https://github.com/OSGeo/libgeotiff.git",
    :branch => "master",
    :commit => "47a3a6bb314e8b8b9125beb9b5715b3837b82c74"
  version "1.5.1"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "8a04f6221105ae65e089abc59efb680e1f264e656f9621eec9012b104dd829d7" => :catalina
    sha256 "8a04f6221105ae65e089abc59efb680e1f264e656f9621eec9012b104dd829d7" => :mojave
    sha256 "8a04f6221105ae65e089abc59efb680e1f264e656f9621eec9012b104dd829d7" => :high_sierra
  end

  revision 3

  head "https://github.com/OSGeo/libgeotiff.git", :branch => "master"

  # keg_only "libgeotiff is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on Unlinked

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "pkgconfig" => :build
  depends_on "jpeg"
  depends_on "zlib"
  depends_on "libtiff"
  depends_on "osgeo-proj"

  def install
    cd "libgeotiff" do
      # autoreconf -fvi
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
