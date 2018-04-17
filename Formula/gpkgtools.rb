require 'formula'

class Gpkgtools < Formula
  homepage 'https://launchpad.net/gpkgtools'
  head "lp:gpkgtools", :using => :bzr

  depends_on 'libspatialite'
  depends_on "python@2"

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/0f/57/25be1a4c2d487942c3ed360f6eee7f41c5b9196a09ca71c54d1a33c968d9/Pillow-5.0.0.tar.gz"
    sha256 "12f29d6c23424f704c66b5b68c02fe0b571504459605cfe36ab8158359b0e1bb"
  end

  def install
    head_ext = "#{HOMEBREW_PREFIX}/Cellar/libspatialite/HEAD/lib/spatialite.dylib"
    unless File.exist? head_ext
      odie <<~EOS
        No libspatialite HEAD build or SQLite3 extension 'spatialite.dylib' exists.
        Install libspatialite using --HEAD and --with-geopackage options'.
        NOTE: To experiment with the HEAD build, but already have libspatialite
              installed, do the following:
                `brew upgrade libspatialite --HEAD --with-geopackage`
                `brew list --versions libspatialite` (note non-HEAD version)
                `brew switch libspatialite <non-HEAD version>`
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
