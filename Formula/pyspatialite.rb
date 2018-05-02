class Pyspatialite < Formula
  desc "DB-API 2.0 interface for SQLite with Spatialite"
  homepage "https://code.google.com/p/pyspatialite/"
  revision 3

  head "https://code.google.com/p/pyspatialite/", :using => :hg

  stable do
    # temporary download of source, prior to pyspatialite move to github
    url "https://osgeo4mac.s3.amazonaws.com/src/pyspatialite-3.0.1.tar.gz"
    sha256 "81a3e4966fb6348802a985486cbf62e019a0fcb0a1e006b9522e8b02dc08f238"
    patch do
      # Patch to work with libspatialite 4.x, drop amalgamation support, dynamically
      # link libspatialite and sqlite3, and fix redeclaration build error
      # Reported upstream: http://code.google.com/p/pyspatialite/issues/detail?id=15
      # (not tested/supported with HEAD builds)
      url "https://gist.github.com/dakcarto/7510460/raw/2e56dd217c19d8dd661e4d3ffb2b669f34da580b/pyspatialite-3.0.1-Mac-patch.diff"
      sha256 "8696caaadfc6edf9aa159fe61ed44ce1eac23da2fd68c242148fc2218e6c6901"
    end
  end

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any
    rebuild 1
    sha256 "39971bed725dfc173fa81a28cc0996bdbe9c44f33d8b144b0de7327042136b46" => :high_sierra
    sha256 "39971bed725dfc173fa81a28cc0996bdbe9c44f33d8b144b0de7327042136b46" => :sierra
  end

  depends_on "python@2"
  depends_on "geos"
  depends_on "proj"
  depends_on "sqlite"
  depends_on "libspatialite"

  def install
    # write setup.cfg
    (buildpath/"setup.cfg").write <<~EOS
      [build_ext]
      include_dirs=#{HOMEBREW_PREFIX}/include/:#{HOMEBREW_PREFIX}/opt/sqlite/include/
      library_dirs=#{HOMEBREW_PREFIX}/lib:#{HOMEBREW_PREFIX}/opt/sqlite/lib
    EOS

    system "python", "setup.py", "build"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import pyspatialite"
    end
  end
end
