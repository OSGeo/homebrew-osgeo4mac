require 'formula'

class Gpkgtools < Formula
  homepage 'https://launchpad.net/gpkgtools'
  head 'bzr://http://bazaar.launchpad.net/~bradh/gpkgtools/trunk'

  depends_on 'libspatialite'
  depends_on :python
  depends_on 'PIL' => :python

  def install
    head_ext = "#{HOMEBREW_PREFIX}/Cellar/libspatialite/HEAD/lib/spatialite.so"
    unless File.exist? head_ext
      odie <<-EOS.undent
        No libspatialite HEAD build or SQLite3 extension 'spatialite.so' exists.
        Install libspatialite using --HEAD and --with-geopackage options'.
        NOTE: To experiment with the HEAD build, but already have libspatialite
              installed, do the following:
                `brew upgrade libspatialite --HEAD --with-geopackage`
                `brew list --versions libspatialite` (note non-HEAD version)
                `brew switch libspatialite <non-HEAD version>`
      EOS
    end
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

  def caveats;
    python.standard_caveats if python
  end

  def test
    cd "#{opt_prefix}" do
      system 'python', 'tests/geonames.py'
    end
  end
end
