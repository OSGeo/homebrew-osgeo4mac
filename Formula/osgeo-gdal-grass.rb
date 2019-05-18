class OsgeoGdalGrass < Formula
  desc "GDAL/OGR 2.x plugin for GRASS 7"
  homepage "https://www.gdal.org"
  url "https://download.osgeo.org/gdal/2.4.1/gdal-grass-2.4.1.tar.gz"
  sha256 "07c30ca725ddf0b9b596d98e744523d86b9f9e8a208ee1f6d4130d1549672157"

  revision 1

  bottle do
    root_url "https://bottle.download.osgeo.org"
    cellar :any
    rebuild 1
    sha256 "da079951807a2bdfdbd8fa7d3998a2afa56c826c748eecd4b286822dff1fcec6" => :mojave
    sha256 "da079951807a2bdfdbd8fa7d3998a2afa56c826c748eecd4b286822dff1fcec6" => :high_sierra
    sha256 "00bc3b008b007e90d92d5bfd76d7cde07eabc20637468eac264ad3efad820967" => :sierra
  end

  depends_on "osgeo-gdal"
  depends_on "osgeo-grass"

  def gdal_majmin_ver
    gdal_ver_list = Formula["osgeo-gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    ENV.cxx11
    gdal = Formula["osgeo-gdal"]
    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

    grass = Formula["osgeo-grass"]

    # due to DYLD_LIBRARY_PATH no longer being setable, strictly define extension
    inreplace "Makefile.in", ".so", ".dylib"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gdal=#{gdal.opt_bin}/gdal-config",
                          "--with-grass=#{grass.prefix}/grass-base",
                          "--with-autoload=#{gdal_plugins}"

    # inreplace "Makefile", "mkdir", "mkdir -p"

    system "make", "install"
  end

  def caveats; <<~EOS
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["osgeo-gdal"].opt_bin
    out = shell_output("#{gdal_opt_bin}/gdalinfo --formats")
    assert_match "GRASS -raster- (ro)", out
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "OGR_GRASS -vector- (ro)", out
  end
end
