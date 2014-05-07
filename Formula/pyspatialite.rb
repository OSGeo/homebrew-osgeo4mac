require 'formula'

class Pyspatialite < Formula
  homepage 'http://code.google.com/p/pyspatialite/'
  # temporary download of source, prior to pyspatialite move to github
  url 'http://qgis.dakotacarto.com/osgeo4mac/pyspatialite-3.0.1.tar.gz'
  sha1 'bcb3fdbc902a1b2f4451f2dad84dbbfba157ed4e'

  head 'https://code.google.com/p/pyspatialite/', :using => :hg

  depends_on :python
  depends_on 'geos'
  depends_on 'proj'
  depends_on 'sqlite'
  depends_on 'libspatialite'

  stable do
    patch do
      # Patch to work with libspatialite 4.x, drop amalgamation support, dynamically
      # link libspatialite and sqlite3, and fix redeclaration build error
      # Reported upstream: http://code.google.com/p/pyspatialite/issues/detail?id=15
      # (not tested/supported with HEAD builds)
      url "https://gist.github.com/dakcarto/7510460/raw/2e56dd217c19d8dd661e4d3ffb2b669f34da580b/pyspatialite-3.0.1-Mac-patch.diff"
      sha1 "bb1738391d018411a385a0c972d4b8cc92c62254"
    end
  end

  def install
    # write setup.cfg
    (buildpath/'setup.cfg').write <<-EOS.undent
      [build_ext]
      include_dirs=#{HOMEBREW_PREFIX}/include/:#{HOMEBREW_PREFIX}/opt/sqlite/include/
      library_dirs=#{HOMEBREW_PREFIX}/lib:#{HOMEBREW_PREFIX}/opt/sqlite/lib
    EOS

    system 'python', 'setup.py', 'build'
    system 'python', 'setup.py', 'install', "--prefix=#{prefix}"
  end
end
