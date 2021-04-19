class Unlinked < Requirement
  fatal true

  satisfy(build_env: false) { !core_libgeotiff_linked }

  def core_libgeotiff_linked
    Formula["libgeotiff"].linked_keg.exist?
  rescue
    false
  end

  def message
    s = "\033[31mYou have other linked versions!\e[0m\n\n"

    if core_libgeotiff_linked
      s += "Unlink with \e[32mbrew unlink libgeotiff\e[0m or remove with brew \e[32muninstall --ignore-dependencies libgeotiff\e[0m\n\n"
    end
    s
  end
end

class OsgeoLibgeotiff < Formula
  desc "Library and tools for dealing with GeoTIFF"
  homepage "https://geotiff.osgeo.org/"
  # url "https://github.com/OSGeo/libgeotiff/releases/download/1.6.0/libgeotiff-1.6.0.tar.gz"
  # sha256 "9311017e5284cffb86f2c7b7a9df1fb5ebcdc61c30468fb2e6bca36e4272ebca"
  url "https://github.com/OSGeo/libgeotiff.git",
    branch: "master",
    commit: "8b1a8f52bc909f86e04ceadd699db102208074a2"
  version "1.6.0"

  head "https://github.com/OSGeo/libgeotiff.git", branch: "master"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    sha256 cellar: :any, catalina:    "bcaf0e372b3a5c3875d695f34660d2efd90a728ade4960e1c7b4d9669bb29177"
    sha256 cellar: :any, mojave:      "bcaf0e372b3a5c3875d695f34660d2efd90a728ade4960e1c7b4d9669bb29177"
    sha256 cellar: :any, high_sierra: "bcaf0e372b3a5c3875d695f34660d2efd90a728ade4960e1c7b4d9669bb29177"
  end

  # revision 3

  # keg_only "libgeotiff is already provided by homebrew/core"
  # we will verify that other versions are not linked
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkgconfig" => :build
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "osgeo-proj"
  depends_on Unlinked
  depends_on "zlib"

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
    assert_match(/GeogInvFlatteningGeoKey.*123.456/, output)
  end
end
