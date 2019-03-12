class Gdal1Grass6 < Formula
  desc "GDAL/OGR 1.x plugin for GRASS 6"
  homepage "http://www.gdal.org"
  url "http://download.osgeo.org/gdal/gdal-grass-1.11.2.tar.gz"
  sha256 "08473ade53d699e1292c54a4271ed0108ec39e0b3a5ebfea04dc88d31e44bd1b"
  revision 1

  # bottle do
  #   root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "gdal"
  depends_on "grass6"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def install
    gdal = Formula["gdal"]
    gdal_plugins = lib/"gdalplugins/#{gdal_majmin_ver}"
    gdal_plugins.mkpath
    (HOMEBREW_PREFIX/"lib/gdalplugins/#{gdal_majmin_ver}").mkpath
    grass = Formula["grass6"]

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

  def caveats; <<~EOS
    This formula provides a plugin that allows GDAL and OGR to access geospatial
    data stored using the GRASS vector and raster formats. In order to use the
    plugin, you will need to add the following path to the GDAL_DRIVER_PATH
    enviroment variable:
      #{HOMEBREW_PREFIX}/lib/gdalplugins/#{gdal_majmin_ver}
    EOS
  end

  test do
    ENV["GDAL_DRIVER_PATH"] = "#{HOMEBREW_PREFIX}/lib/gdalplugins"
    gdal_opt_bin = Formula["gdal"].opt_bin
    out = `#{gdal_opt_bin}/gdalinfo --formats`
    assert_match "GRASS (ro)", out
    out = `#{gdal_opt_bin}/ogrinfo --formats`
    assert_match "\"GRASS\" (readonly)", out
  end
end
