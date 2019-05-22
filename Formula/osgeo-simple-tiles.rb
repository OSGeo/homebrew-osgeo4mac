class OsgeoSimpleTiles < Formula
  desc "Image generation library for spatial data"
  homepage "https://propublica.github.io/simple-tiles"
  url "https://github.com/propublica/simple-tiles/archive/v0.6.1.tar.gz"
  sha256 "2391b2f727855de28adfea9fc95d8c7cbaca63c5b86c7286990d8cbbcd640d6f"

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "fec2a26451465b4e4d895e2ef383b20240af7f6956d57b5ea70fd7fcf059d47e" => :mojave
    sha256 "fec2a26451465b4e4d895e2ef383b20240af7f6956d57b5ea70fd7fcf059d47e" => :high_sierra
    sha256 "e1d77cc94e155ce5067b5f84d3b5dc781b3f5014eab0a5d18ce77681cbb9ecaa" => :sierra
  end

  revision 2

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
