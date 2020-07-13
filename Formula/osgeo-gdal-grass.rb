class OsgeoGdalGrass < Formula
  desc "GDAL/OGR 3.x plugin for GRASS 7"
  homepage "https://www.gdal.org"
  url "https://download.osgeo.org/gdal/3.1.2/gdal-3.1.2.tar.xz"
  sha256 "767c8d0dfa20ba3283de05d23a1d1c03a7e805d0ce2936beaff0bb7d11450641"

  #revision 1

  #bottle do
  #  root_url "https://bottle.download.osgeo.org"
  #  cellar :any
  #  sha256 "24d80b0a8250aee06a5af69277371f582b24e87036c091f0b174268a898b2ae0" => :mojave
  #  sha256 "24d80b0a8250aee06a5af69277371f582b24e87036c091f0b174268a898b2ae0" => :high_sierra
  #  sha256 "736afd0da344f3b221bc0b4e58019970b50552d40e2472b00ff8872248f5a977" => :sierra
  #end

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
