class OsgeoSimpleTiles < Formula
  desc "Image generation library for spatial data"
  homepage "https://propublica.github.io/simple-tiles/"
  url "https://github.com/propublica/simple-tiles/archive/v0.6.1.tar.gz"
  sha256 "2391b2f727855de28adfea9fc95d8c7cbaca63c5b86c7286990d8cbbcd640d6f"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    sha256 "cf3b55ed85ec7e3c84d487633831fe92a87382b024ddc7cb506f335daacc3c4a" => :mojave
    sha256 "cf3b55ed85ec7e3c84d487633831fe92a87382b024ddc7cb506f335daacc3c4a" => :high_sierra
    sha256 "4cecd6dd82c66d4648fa72e6220a21be6d6cbb0c820d39cd8974f4d3718258e3" => :sierra
  end

  # revision 1

  head "https://github.com/propublica/simple-tiles.git", :branch => "master"

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "pango"
  depends_on "osgeo-gdal"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <simple-tiles/simple_tiles.h>

      int main(){
        simplet_map_t *map = simplet_map_new();
        simplet_map_free(map);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lsimple-tiles",
           "-I#{Formula["cairo"].opt_include}/cairo",
           "-I#{Formula["osgeo-gdal"].opt_include}",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           "-I#{Formula["pango"].opt_include}/pango-1.0",
           "test.c", "-o", "test"
    system testpath/"test"
  end
end
