require 'formula'

class OsgeoGpkgtools < Formula
  desc "Some tools for the GeoPackage mapping (vector, tiles and raster) container"
  homepage 'https://launchpad.net/gpkgtools'

  # revision 1

  head "lp:gpkgtools", :using => :bzr

  depends_on 'osgeo-libspatialite'
  depends_on "python@2"

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/3c/7e/443be24431324bd34d22dd9d11cc845d995bcd3b500676bcf23142756975/Pillow-5.4.1.tar.gz"
    sha256 "5233664eadfa342c639b9b9977190d64ad7aca4edc51a966394d7e08e7f38a9f"
  end

  def install
    head_ext = "#{HOMEBREW_PREFIX}/Cellar/osgeo-libspatialite/HEAD/lib/spatialite.dylib"
    unless File.exist? head_ext
      odie <<~EOS
        No osgeo-libspatialite HEAD build or SQLite3 extension 'spatialite.dylib' exists.
        Install osgeo-libspatialite using --HEAD and --with-geopackage options'.
        NOTE: To experiment with the HEAD build, but already have osgeo-libspatialite
              installed, do the following:
                `brew upgrade osgeo-libspatialite --HEAD --with-geopackage`
                `brew list --versions osgeo-libspatialite` (note non-HEAD version)
                `brew switch osgeo-libspatialite <non-HEAD version>`
      EOS
    end

    resource("Pillow").stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }

    cd 'gpkgtools' do
      inreplace %w[util_sqlite.py GeoPackage.py] do |s|
        s.sub! 'from pysqlite2', '#from pysqlite2'
        s.sub! '#import sqlite3', 'import sqlite3'
        s.sub! /load_extension\(.*spatialite"\)/, "load_extension('#{head_ext}')"
      end
    end

    (lib/python.xy/'site-packages').install 'gpkgtools'
    bin.install Dir['*gpkg*']
    prefix.install %w[tests testdata]
  end

  test do
    cd "#{opt_prefix}" do
      system 'python', 'tests/geonames.py'
    end
  end
end
