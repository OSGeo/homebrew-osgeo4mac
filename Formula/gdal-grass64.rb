require 'formula'

class GdalGrass64 < Formula
  homepage 'http://www.gdal.org'
  url 'http://download.osgeo.org/gdal/gdal-grass-1.4.3.tar.gz'
  sha1 '63b87ad1688cc365dc6bd6c3ccc854d0e6aa637a'
  revision 1

  bottle do
    root_url "http://qgis.dakotacarto.com/osgeo4mac/bottles"
    sha1 "f404547c07cdee365e5b96f71405ff304d03d91a" => :mavericks
    sha1 "d5a0dffa38a112208d59c11d30085e2247813f9f" => :yosemite
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

  def caveats; <<-EOS.undent
    This formula provides a plugin that allows GDAL and OGR to access geospatial
    data stored using the GRASS vector and raster formats. In order to use the
    plugin, you will need to add the following path to the GDAL_DRIVER_PATH
    enviroment variable:
      #{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end
end
