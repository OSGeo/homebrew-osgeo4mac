class Gdal2Grass7 < Formula
  desc "GDAL/OGR 2.x plugin for GRASS 7"
  homepage "http://www.gdal.org"
  url "http://download.osgeo.org/gdal/2.2.4/gdal-grass-2.2.4.tar.gz"
  sha256 "7dfe193cd2d7e9cc5dd68d2532b219e18fb2321f25f52969b4039995768b8631"

  # bottle do
  #   root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
  #   sha256 "" => :mavericks
  # end

  depends_on "gdal2"
  depends_on "grass7"

  def gdal_majmin_ver
    gdal_ver_list = Formula["gdal2"].version.to_s.split(".")
    "#{gdal_ver_list[0]}.#{gdal_ver_list[1]}"
  end

  def gdal_plugins_subdirectory
    "gdalplugins/#{gdal_majmin_ver}"
  end

  def install
    gdal = Formula["gdal2"]
    gdal_plugins = lib/gdal_plugins_subdirectory
    gdal_plugins.mkpath

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

  def caveats; <<~EOS
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
