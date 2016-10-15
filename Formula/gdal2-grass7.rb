class Gdal2Grass7 < Formula
  desc "GDAL/OGR 2.x plugin for GRASS 7"
  homepage "http://www.gdal.org"
  url "http://download.osgeo.org/gdal/2.1.0/gdal-grass-2.1.0.tar.gz"
  sha256 "1faa5d244ebcb5295cab7814c661ba1dee72b27c0e3848677e34b0c97c8111d0"

  # bottle do
  #   root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "gdal2"
  depends_on "grass7"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal2"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def install
    gdal = Formula["gdal2"]
    gdal_plugins = lib/"gdalplugins/#{gdal_majmin_ver}"
    gdal_plugins.mkpath
    (HOMEBREW_PREFIX/"lib/gdalplugins/#{gdal_majmin_ver}").mkpath
    grass = Formula["grass7"]

    # due to DYLD_LIBRARY_PATH no longer being setable, strictly define extension
    inreplace "Makefile.in", ".so", ".dylib"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gdal=#{gdal.opt_bin}/gdal-config",
                          "--with-grass=#{grass.prefix}/grass-#{grass.version}",
                          "--with-autoload=#{gdal_plugins}"

    inreplace "Makefile", "mkdir", "mkdir -p"

    system "make", "install"
  end

  def caveats; <<-EOS.undent
    This formula provides a plugin that allows GDAL and OGR to access geospatial
    data stored using the GRASS vector and raster formats. In order to use the
    plugin, you will need to add the following path to the GDAL_DRIVER_PATH
    enviroment variable:
      #{HOMEBREW_PREFIX}/lib/gdalplugins/#{gdal_majmin_ver}
    EOS
  end

  test do
    gdal_opt_bin = Formula["gdal2"].opt_bin
    out = `#{gdal_opt_bin}/gdalinfo --formats`
    assert_match "GRASS -raster- (ro)", out
    out = `#{gdal_opt_bin}/ogrinfo --formats`
    assert_match "OGR_GRASS -vector- (ro)", out
  end
end
