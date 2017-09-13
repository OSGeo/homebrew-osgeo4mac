class Gdal2Grass7 < Formula
  desc "GDAL/OGR 2.x plugin for GRASS 7"
  homepage "http://www.gdal.org"
  url "http://download.osgeo.org/gdal/2.2.0/gdal-grass-2.2.0.tar.gz"
  sha256 "0eb2b541e87db4c0d1b3cdc61512b88631e6f7d39db5986eeb773aada0a7995f"
  revision 1

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "gdal2"
  depends_on "grass7"

  def install
    gdal = Formula["gdal2"]
    gdal_plugins = lib/gdal.plugins_subdirectory.to_s
    gdal_plugins.mkpath
    (HOMEBREW_PREFIX/"lib/#{gdal.plugins_subdirectory}").mkpath
    grass = Formula["grass7"]

    # due to DYLD_LIBRARY_PATH no longer being setable, strictly define extension
    inreplace "Makefile.in", ".so", ".dylib"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gdal=#{gdal.opt_bin}/gdal-config",
                          "--with-grass=#{grass.prefix}/grass-#{grass.version}",
                          "--with-autoload=#{gdal_plugins}"

    # inreplace "Makefile", "mkdir", "mkdir -p"

    system "make", "install"
  end

  def caveats; <<-EOS.undent
      This formula provides a plugin that allows GDAL or OGR to access geospatial
      data stored in its format. In order to use the shared plugin, you may need
      to set the following enviroment variable:

        export GDAL_DRIVER_PATH=#{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["gdal2"].opt_bin
    out = shell_output("#{gdal_opt_bin}/gdalinfo --formats")
    assert_match "GRASS -raster- (ro)", out
    out = shell_output("#{gdal_opt_bin}/ogrinfo --formats")
    assert_match "OGR_GRASS -vector- (ro)", out
  end
end
