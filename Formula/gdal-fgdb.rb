require 'formula'

class GdalThirdParty < Requirement
  fatal true

  satisfy do
    envar = ENV['GDAL_THIRD_PARTY']
    envar && File.exists?(envar)
  end

  def message; <<-EOS.undent
    Define GDAL_THIRD_PARTY environment variable that points to a directory,
    which contains the unaltered download archive of the third-party library:

      `export GDAL_THIRD_PARTY=path/to/gdal/third_party/directory`

    EOS
  end
end

class GdalFgdb < Formula
  homepage 'http://www.gdal.org/ogr/drv_filegdb.html'
  url 'http://download.osgeo.org/gdal/1.10.1/gdal-1.10.1.tar.gz'
  sha1 'b4df76e2c0854625d2bedce70cc1eaf4205594ae'

  depends_on GdalThirdParty
  depends_on 'gdal'

  resource 'fgdb' do
    url "file://#{ENV['GDAL_THIRD_PARTY']}/FileGDB_API_1_3-64.zip"
    sha1 '95ba7e3da555508c8be10b8dbb6ad88a71b03f49'
  end

  def install
    resource('fgdb').stage do
      raise ''
    end

    gdal = Formula.factory('gdal')


    # inreplace "Makefile", 'mkdir', 'mkdir -p'
#     system "make install"
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
