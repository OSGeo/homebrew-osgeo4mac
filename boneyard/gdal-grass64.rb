require 'formula'

class GdalGrass64 < Formula
  homepage 'http://www.gdal.org'
  url 'http://download.osgeo.org/gdal/gdal-grass-1.4.3.tar.gz'
  sha256 'ea18d1e773e8875aaf3261a6ccd2a5fa22d998f064196399dfe73d991688f1dd'
  revision 1

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha256 "93be8a55d7855eb95e08fe888ec7ce893aa1d2e34d91f8a19669d56c9c060c27" => :mavericks
    sha256 "30f9c487696e908e73efbf74702668ad896d68a7238e529dd19671255b15e651" => :yosemite
    sha256 "43fdc5d8e5b6ac67f05551fca316bc5f91e36e14cb3bc5cdd698516a724748f8" => :el_capitan
  end

  depends_on 'gdal'
  depends_on 'grass-64'

  conflicts_with 'gdal-grass', :because => 'both install same-named gdal plugin'

  def install
    gdal = Formula['gdal']
    grass = Formula['grass-64']

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gdal=#{gdal.bin}/gdal-config",
                          "--with-grass=#{grass.prefix}/grass-#{grass.version}",
                          "--with-autoload=#{lib}/gdalplugins"

    inreplace "Makefile", 'mkdir', 'mkdir -p'

    system "make install"
  end

  def caveats; <<~EOS
    This formula provides a plugin that allows GDAL and OGR to access geospatial
    data stored using the GRASS vector and raster formats. In order to use the
    plugin, you will need to add the following path to the GDAL_DRIVER_PATH
    enviroment variable:
      #{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end
end
