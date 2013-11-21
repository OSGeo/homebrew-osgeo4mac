require 'formula'

class GdalPlugins < Formula
  homepage 'http://www.gdal.org/'
  url 'http://download.osgeo.org/gdal/1.10.1/gdal-1.10.1.tar.gz'
  sha1 'b4df76e2c0854625d2bedce70cc1eaf4205594ae'

  option 'with-grass' 'Build GRASS plugin from homebrew `gdal-grass` package'

  depends_on 'gdal'
  depends_on 'gdal-grass' if build.with? 'grass'

  def install
    grass = Formula.factory('grass')

    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gdal=#{HOMEBREW_PREFIX}/bin/gdal-config",
                          "--with-grass=#{grass.prefix}/grass-#{grass.version}",
                          "--with-autoload=#{lib}/gdalplugins"

    inreplace "Makefile", 'mkdir', 'mkdir -p'

    system "make install"
  end

  def caveats; <<-EOS.undent
    This formula provides a plugins that allows GDAL and OGR to access geospatial
    data sources in other geospatial tools or formats. In order to use the
    plugin, you will need to add the following path to the GDAL_DRIVER_PATH
    enviroment variable:
      #{HOMEBREW_PREFIX}/lib/gdalplugins
    EOS
  end
end
